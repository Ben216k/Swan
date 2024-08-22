// 
//  SUCLToolsResolved.swift - Swan
// 
//  Created by Ben216k on 8/21/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import os
import SwiftUI

struct SUCLToolsResolved: SUProductResolved {
    
    let key: String
    let serverMetadataURL: String?
    var packages: [SUPackage]
    let postDate: Date
    let distributions: [String : String]
    let extendedMetaInfo: SUExtendedMetadata?
    let type: SUProductType = .cltools
    var insideCatalogs: [String]
    var serverMetadata: SUServerMetadata?
    var releaseType: SUCatalogType = .release
    var deferredSUEnablementDate: Date?

    var version: String
    
    var basicName: String { "Command Line Tools" } 
    
    var downloadTitleText: String { "\(basicName) \(version)" }
    var downloadSubtitleText: String { 
        "For Xcode" // Assuming you have an Xcode version property
    }
    
    var image: Image { Image(imageName) }
    var imageName: String { version.contains("beta") ? "CLToolsBetaCircle" : "CLToolsCircle" }

    var betaNumber: String? {
        guard let title = serverMetadata?.localizations["English"]?.title else { return nil }
        print(title)

        // Define the regex pattern to capture the beta number
        let pattern = #"beta (\d+)"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(title.startIndex..<title.endIndex, in: title)
            
            if let match = regex.firstMatch(in: title, options: [], range: range) {
                if let betaRange = Range(match.range(at: 1), in: title) {
                    return String(title[betaRange])
                }
            }
        } catch {
            // that's fine
        }
        
        return nil
    }
}

// MARK: - Resolving CLTools 

extension SUCLToolsResolved {
    static func resolve(from product: SUProduct) async throws -> SUCLToolsResolved {

        let resolved = SUCLToolsResolved(
            key: product.key, 
            serverMetadataURL: product.serverMetadataURL, 
            packages: product.packages, 
            postDate: product.postDate, 
            distributions: product.distributions, 
            extendedMetaInfo: product.extendedMetaInfo, 
            insideCatalogs: product.insideCatalogs, 
            deferredSUEnablementDate: product.deferredSUEnablementDate,
            version: "N/A"
        )

        

        return resolved
    }
}
