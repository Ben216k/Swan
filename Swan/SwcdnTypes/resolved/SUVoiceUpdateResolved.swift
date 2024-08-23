// 
//  SUVoiceUpdateResolved.swift - Swan
// 
//  Created by Ben216k on 8/22/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import SwiftUI

struct SUVoiceUpdateResolved: SUProductResolved {
    
    let key: String
    let serverMetadataURL: String?
    var packages: [SUPackage]
    let postDate: Date
    let distributions: [String : String]
    let extendedMetaInfo: SUExtendedMetadata?
    var type: SUProductType = .voiceupdate
    var insideCatalogs: [String]
    var serverMetadata: SUServerMetadata?
    var releaseType: SUCatalogType = .release
    var deferredSUEnablementDate: Date?
    
    var version: String = "N/A" 
    var deprecated = false

    enum VoiceSubtype: String, CaseIterable, Codable {
        case custom = "Custom"
        case mlv = "MLV"
        case speech = "Speech"
    }

    var subtype: VoiceSubtype
    var isUpdate: Bool
    var local: String
    var personName: String = "N/A" // Default value
    var isLegacy: Bool
    
    var basicName: String {
        "\(personName.isEmpty || personName == "N/A" ? "" : "\(personName) ")\(local != "N/A" ? "\(local) " : "")\(subtype.rawValue) Voice\(isUpdate ? " Update" : "")\(isLegacy ? " Legacy" : "")"
    }

    var formattedName: String { // Without person name
        "\(local != "N/A" ? "\(local) " : "")\(subtype.rawValue) Voice\(isUpdate ? " Update" : "")\(isLegacy ? " Legacy" : "")"
    }

    var imageName: String { "\(subtype.rawValue)Voice\(isUpdate ? "Update" : "")Circle" }
    
    var downloadTitleText: String {
            "\(personName) \(local) \(subtype.rawValue) Voice\(isUpdate ? " Update" : "")"
        }
        
        var downloadSubtitleText: String {
            isLegacy ? "Legacy" : ""
        }
        
        var image: Image {
            Image(imageName)
        }
}

// MARK: - Resolving Voice Updates

extension SUVoiceUpdateResolved {
    static func resolve(from product: SUProduct) async throws -> SUVoiceUpdateResolved {
        var resolved = SUVoiceUpdateResolved(
            key: product.key,
            serverMetadataURL: product.serverMetadataURL,
            packages: product.packages,
            postDate: product.postDate,
            distributions: product.distributions,
            extendedMetaInfo: product.extendedMetaInfo,
            insideCatalogs: product.insideCatalogs,
            deferredSUEnablementDate: product.deferredSUEnablementDate,
            subtype: .custom, // Placeholder, will be determined below
            isUpdate: false,  // Placeholder, will be determined below
            local: "N/A",      // Placeholder, will be determined below
            isLegacy: false   // Placeholder, will be determined below
        )

        guard let serverMetadataURL = product.serverMetadataURL,
              let lastComponent = serverMetadataURL.urlLastPathCompenent
        else { 
            return resolved // Return with default values
        }

        // Determine subtype, isUpdate, and local
        if serverMetadataURL.contains("CustomVoice") {
            resolved.subtype = .custom
        } else if serverMetadataURL.contains("MLV") {
            resolved.subtype = .mlv
        } else if serverMetadataURL.contains("MultiLingualVoice") {
            resolved.subtype = .mlv
        } else if serverMetadataURL.contains("SpeechVoice") {
            resolved.subtype = .speech
        }
        
        resolved.isUpdate = serverMetadataURL.contains("Update")

        // Extract local (handle Legacy case)
        let parts = lastComponent.components(separatedBy: "_")
        if parts.count >= 3 {
            resolved.local = parts[1] + "_" + parts[2]
        }
        if parts.count >= 4 {
            resolved.personName = parts[3].capitalized
        }
        resolved.isLegacy = serverMetadataURL.contains("Legacy")

        return resolved
    }
}
