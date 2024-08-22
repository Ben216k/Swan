// 
//  SUSecurityUpdateResolved.swift - Swan
// 
//  Created by Ben216k on 8/21/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import SwiftUI

struct SUSecurityUpdateResolved: SUProductResolved {
    let key: String
    let serverMetadataURL: String?
    var packages: [SUPackage]
    let postDate: Date
    let distributions: [String : String]
    let extendedMetaInfo: SUExtendedMetadata?
    var type: SUProductType = .securityupdate
    var insideCatalogs: [String]
    var serverMetadata: SUServerMetadata?
    var releaseType: SUCatalogType = .release
    var deferredSUEnablementDate: Date?

    var version: String = "N/A"
    var securityUpdateID: String = "N/A"
    var macOSVersion: String = "Unknown"

    var basicName: String { "\(macOSVersion) Security Update" }

    var downloadTitleText: String { "\(basicName) \(version)" }
    var downloadSubtitleText: String { "For \(macOSVersion)" }

    var image: Image { Image(imageName) }
    var imageName: String { "\(macOSVersion.replacingOccurrences(of: " ", with: ""))SecurityCircle" }
}

// MARK: - Resolving Security Updates

extension SUSecurityUpdateResolved {
    static func resolve(from product: SUProduct) async throws -> SUSecurityUpdateResolved {
        var resolved = SUSecurityUpdateResolved(
            key: product.key,
            serverMetadataURL: product.serverMetadataURL,
            packages: product.packages,
            postDate: product.postDate,
            distributions: product.distributions,
            extendedMetaInfo: product.extendedMetaInfo,
            insideCatalogs: product.insideCatalogs,
            deferredSUEnablementDate: product.deferredSUEnablementDate
        )

        guard let serverMetadataURL = product.serverMetadataURL else {
            return resolved // Return with default "N/A" values
        }
        
        guard let lastComp = serverMetadataURL.urlLastPathCompenent else {
            return resolved
        }

        if serverMetadataURL.contains("SecUpdSrvr") {
            resolved.securityUpdateID = String(lastComp.replacingOccurrences(of: "SecUpdSrvr", with: "").replacingOccurrences(of: ".smd", with: ""))
            resolved.macOSVersion = "Server"
        } else {
            resolved.securityUpdateID = String(lastComp.replacingOccurrences(of: "SecUpd", with: "").prefix(8))
            resolved.macOSVersion = addSpaceBeforeCapitalLetters(in: String(lastComp.dropFirst(14)).replacingOccurrences(of: ".smd", with: ""))
        }

        return resolved
    }
}
