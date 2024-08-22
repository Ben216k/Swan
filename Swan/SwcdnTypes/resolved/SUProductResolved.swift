// 
//  SUProductResolved.swift - Swan
//
//  Created by Ben216k on 7/31/24
//  Copyright (c) Ben216k (under 216k License)
// 

import Foundation
import SwiftUI

// To do this, we will use multiple structs for the different types of products, all of which conform to the SUProductResolved protocol.

// MARK: - SUProductResolved

/// A product that has been resolved to a specific version
protocol SUProductResolved: Sendable, Identifiable where ID == String {
    
    var key: String { get }
    
    /// Server Metadata URL
    var serverMetadataURL: String? { get }
    
    /// Packages in the product
    var packages: [SUPackage] { get set }
    
    /// Post Date
    var postDate: Date { get }
    
    /// Distributions in the product, yay!
    /// BE CAREFUL: The key is the locale, which is sometimes `zh_TW` and sometimes `English`, and it's usually the same for each language, but still goofy.
    var distributions: [String: String] { get }
    
    /// ExtendedMetaInfo, yes it's a cursed type, but it's just a dictionary of dictionaries
    /// InstallAssistantPackageIdentifiers is the only one I've ever seen.
    var extendedMetaInfo: SUExtendedMetadata? { get }
    
    /// Type of product
    var type: SUProductType { get }
    
    var insideCatalogs: [String] { get }
    
    var serverMetadata: SUServerMetadata? { get set }
    
    var releaseType: SUCatalogType { get set }

    var deferredSUEnablementDate: Date? { get }
    
    var downloadTitleText: String { get }
    var downloadSubtitleText: String { get }
    
    var image: Image { get }
    var imageName: String { get }
    
    var version: String { get set }
    var basicName: String { get }
    var noOverrideVersion: Bool { get }
}

extension SUProductResolved {
    var id: String { key }
    var noOverrideVersion: Bool { false }
}

// MARK: - SUProductType

/// The type of product
enum SUProductType: Sendable {

    /// macOS releases with full installers, basically anything later than macOS 11.
    case macOSpackage
    case safari
    case bridgeOS
    case cltools
    case securityupdate
    case unknown
    
    var localizedKey: LocalizedStringKey {
        switch self {
        case .macOSpackage:
            return "swui.macospackages"
        case .safari:
            return "swui.safaripackages"
        case .bridgeOS:
            return "swui.bridgeosupdates"
        case .cltools:
            return "swui.cltools"
        case .securityupdate:
            return "swui.securityupdates"
        case .unknown:
            return "swui.unknownproductype"
        }
    }
}

// MARK: - Resolving a Product

extension SUProduct {

    /// Resolves the product to a specific version
    func resolve() async -> any SUProductResolved {
        
        var resolved: any SUProductResolved
        
        do {
            
            // Check for InstallAssistant.pkg url in the packages, if it exists, it's a full macOS installer
            if packages.contains(where: { $0.url.contains("InstallAssistant.pkg") || $0.url.contains("InstallAssistantAuto.pkg") }) {
                resolved = try await SUMacOSPackage.resolve(from: self)
            } else if serverMetadataURL?.contains("Safari") == true {
                resolved = try await SUSafariResolved.resolve(from: self)
            } else if extendedMetaInfo?.productType == "bridgeOS" {
                resolved = await SUBridgeOSProduct.resolve(from: self)
            }  else if serverMetadataURL?.contains("CLTools") == true {
                resolved = try await SUCLToolsResolved.resolve(from: self)
            } else if serverMetadataURL?.contains("SecUpd") == true {
                resolved = try await SUSecurityUpdateResolved.resolve(from: self)
            } else {
                // Otherwise, it's an unknown product, which isn't supported
                throw SWError(source: "SUProduct", id: "swerror.product.unknown")
            }
            
        } catch {
            
            resolved = await SUUnresolvedProduct.resolve(from: self)
            
        }
//        #if DEBUG
        if resolved.type == .unknown { return resolved }
//        #endif
        resolved.serverMetadata = try? await self.resolveServerMetadata()
        if !resolved.noOverrideVersion || resolved.version == "N/A" {
            resolved.version = resolved.serverMetadata?.version ?? resolved.version
        }
        
        if let betaNumber = (resolved as? SUCLToolsResolved)?.betaNumber {
            resolved.version += " beta \(betaNumber)"
        } else if let securityUpdate = resolved as? SUSecurityUpdateResolved, securityUpdate.securityUpdateID != "N/A" {
            resolved.version += " \(securityUpdate.securityUpdateID)"
        }
        
        if insideCatalogs.contains(where: { !$0.contains("seed") && !$0.contains("beta") }) {
            resolved.releaseType = .release
        } else if insideCatalogs.contains(where: { $0.contains("beta") }) {
            resolved.releaseType = .beta
        } else {
            resolved.releaseType = .seed
        }
        
        // Sort packages alphabetically by name, with bias for names starting with "InstallAssistant"
        resolved.packages.sort { (package1, package2) in
            if package1.name.starts(with: "InstallAssistant") && !package2.name.starts(with: "InstallAssistant") {
                return true
            } else if !package1.name.starts(with: "InstallAssistant") && package2.name.starts(with: "InstallAssistant") {
                return false
            } else {
                return package1.name < package2.name
            }
        }
        
        return resolved
    }

}

// MARK: - SwiftUI Stuff

extension SUProductResolved {

    var postDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: postDate)
    }
    
    var postDateFormattedLong: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: postDate)
    }

    var postDateForSorting: String {
        return "\(Int(postDate.timeIntervalSince1970))"
    }

    // defferedSUEnablementDateFormattedLong is a computed property that returns the deferredSUEnablementDate as a formatted string
    var deferredSUEnablementDateFormattedLong: String? {
        guard let date = deferredSUEnablementDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - SUFakedResolved

/// Since protocols can't conform to Identifiable, we need a faked resolved product when trying to use the generic as a type.
/// This takes any SUProductResolved and fakes it as a SUFakedResolved.
struct SUFakedResolved: SUProductResolved {    
    
    var _underlying: any SUProductResolved

    var key: String { _underlying.key }
    var serverMetadataURL: String? { _underlying.serverMetadataURL }
    var packages: [SUPackage] {
        get { _underlying.packages }
        set { _underlying.packages = newValue }
    }
    var postDate: Date { _underlying.postDate }
    var distributions: [String: String] { _underlying.distributions }
    var extendedMetaInfo: SUExtendedMetadata? { _underlying.extendedMetaInfo }
    var type: SUProductType { _underlying.type }
    var insideCatalogs: [String] { _underlying.insideCatalogs }
    var serverMetadata: SUServerMetadata? {
        get { _underlying.serverMetadata }
        set { _underlying.serverMetadata = newValue }
    }
    var releaseType: SUCatalogType {
        get { _underlying.releaseType }
        set { _underlying.releaseType = newValue }
    }
    var deferredSUEnablementDate: Date? { _underlying.deferredSUEnablementDate }
    var downloadTitleText: String { _underlying.downloadTitleText }
    var downloadSubtitleText: String { _underlying.downloadSubtitleText }
    var image: Image { _underlying.image }
    var imageName: String { _underlying.imageName }
    var version: String {
        get { _underlying.version }
        set { _underlying.version = newValue }
    }
    var basicName: String { _underlying.basicName }

    var id: String { _underlying.id }

    init(_ underlying: any SUProductResolved) {
        self._underlying = underlying
    }
}
