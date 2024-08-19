// 
//  SUSafariResolved.swift - Swan
//
//  Created by Ben216k on 8/11/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import os
import SwiftUI

// MARK: - SUSafariResolved

struct SUSafariResolved: SUProductResolved {
    
    let key: String
    let serverMetadataURL: String?
    var packages: [SUPackage]
    let postDate: Date
    let distributions: [String : String]
    let extendedMetaInfo: SUExtendedMetadata?
    let type: SUProductType = .safari
    let version: String
    let macOSVersion: String
    let insideCatalogs: [String]
    var releaseType: SUCatalogType = .release
    var deferredSUEnablementDate: Date?
    
}

// MARK: - Resolving the Safari full product

extension SUSafariResolved {
    
    static func resolve(from product: SUProduct) async throws -> SUSafariResolved {
        
        // Use Regex to extract version number from serverMetadataURL. Safari14.1.2MojaveAuto.smd or Safari17.6VenturaAuto.smd
        
        guard let serverMetadataURL = product.serverMetadataURL else {
            os_log(
                "No serverMetadataURL found for Safari product. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.safari.noservermetadataurl")
        }
        
        // Regex: Safari(\d+\.\d+\.\d+)(\w+)
        let versionRegex = try NSRegularExpression(pattern: "Safari(\\d+\\.\\d+(\\.\\d+)?)(\\w+)", options: [])
        let versionMatches = versionRegex.matches(in: serverMetadataURL, options: [], range: NSRange(location: 0, length: serverMetadataURL.count))

        guard let versionMatch = versionMatches.first else {
            os_log(
                "No version number found for Safari product. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.safari.noversionnumber")
        }

        let versionRange = versionMatch.range(at: 1)
        let version = (serverMetadataURL as NSString).substring(with: versionRange)

        // now we need to extract the macOS version from the serverMetadataURL, which is just the second group in the regex
        let macOSVersionRange = versionMatch.range(at: 3)
        
//        print(serverMetadataURL, version, macOSVersionRange)
        
        var macOSVersion = (serverMetadataURL as NSString).substring(with: macOSVersionRange).replacingOccurrences(of: "Auto", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        macOSVersion = addSpaceBeforeCapitalLetters(in: macOSVersion)

        // yay, we have the version and macOS version now

        return SUSafariResolved(
            key: product.key,
            serverMetadataURL: product.serverMetadataURL,
            packages: product.packages,
            postDate: product.postDate,
            distributions: product.distributions,
            extendedMetaInfo: product.extendedMetaInfo,
            version: version,
            macOSVersion: macOSVersion,
            insideCatalogs: product.insideCatalogs,
            deferredSUEnablementDate: product.deferredSUEnablementDate
        )
            
    }
    
}

func addSpaceBeforeCapitalLetters(in input: String) -> String {
    let pattern = "([A-Z])"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: input.utf16.count)
    let modifiedString = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: " $1")
    
    // Trim leading spaces if any
    return modifiedString.trimmingCharacters(in: .whitespaces)
}
