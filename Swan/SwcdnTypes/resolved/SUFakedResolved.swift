// 
//  SUFakedResolved.swift - Swan
// 
//  Created by Ben216k on 8/22/24
//  Copyright (c) Ben216k (under 216k License)
//

import SwiftUI

/// Since protocols can't conform to Identifiable, we need a faked resolved product when trying to use the generic as a type.
/// This takes any SUProductResolved and fakes it as a SUFakedResolved.
struct SUFakedResolved: SUProductResolved {
    
    var _underlying: any SUProductResolved
    
    // MARK: Base Faked Types

    var key: String { _underlying.key }
    var serverMetadataURL: String? { _underlying.serverMetadataURL }
    var packages: [SUPackage] {
        get { _underlying.packages }
        set { _underlying.packages = newValue }
    }
    var postDate: Date { _underlying.postDate }
    var distributions: [String: String] { _underlying.distributions }
    var extendedMetaInfo: SUExtendedMetadata? { _underlying.extendedMetaInfo }
    var type: SUProductType {
        get { _underlying.type }
        set { _underlying.type = newValue }
    }
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
    var deprecated: Bool {
        get { _underlying.deprecated }
        set { _underlying.deprecated = newValue }
    }

    var id: String { _underlying.id }
    
    // MARK: - macOS Package Specific
    
    var buildNumber: String { (_underlying as? SUMacOSPackage)?.buildNumber ?? "N/A" }
    
    // MARK: - Safari Package Specific
    
    var macOSVersion: String { (_underlying as? SUSafariResolved)?.macOSVersion ?? "N/A" }
    
    // MARK: - Initializers

    init(_ underlying: any SUProductResolved) {
        self._underlying = underlying
    }
    
    init(from decoder: any Decoder) throws {
        throw SWError(source: "SUFakedResolved.init(from:)", id: "swerror.negative.faked")
    }
    
    func encode(to encoder: any Encoder) throws {
        throw SWError(source: "SUFakedResolved.encode(to:)", id: "swerror.negative.faked")
    }
}
