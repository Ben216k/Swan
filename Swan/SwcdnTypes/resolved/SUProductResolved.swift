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
}

extension SUProductResolved {
    var id: String { key }
}

// MARK: - SUProductType

/// The type of product
enum SUProductType: Sendable {

    /// macOS releases with full installers, basically anything later than macOS 11.
    case macOSpackage
    case safari
}

// MARK: - Resolving a Product

extension SUProduct {

    /// Resolves the product to a specific version
    func resolve() async throws -> any SUProductResolved {

        var resolved: any SUProductResolved
        
        // Check for InstallAssistant.pkg url in the packages, if it exists, it's a full macOS installer
        if packages.contains(where: { $0.url.contains("InstallAssistant.pkg") || $0.url.contains("InstallAssistantAuto.pkg") }) {
            resolved = try await SUMacOSPackage.resolve(from: self)
        } else if serverMetadataURL?.contains("SafariTechPreivew") == true {
            throw SWError(source: "SUProduct", id: "swerror.product.unknown")
        } else if serverMetadataURL?.contains("Safari") == true {
            resolved = try await SUSafariResolved.resolve(from: self)
        } else {
            // Otherwise, it's an unknown product, which isn't supported
            throw SWError(source: "SUProduct", id: "swerror.product.unknown")
        }
        
        resolved.serverMetadata = try? await self.resolveServerMetadata()
        resolved.version = resolved.serverMetadata?.version ?? resolved.version

        // Determine the release type, by getting what catalogs it's in and checking if it's in a seed/beta catalog (check for none, then beta, then seed)
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
