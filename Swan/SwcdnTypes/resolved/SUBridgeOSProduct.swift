// 
//  SUBridgeOSProduct.swift - Swan
// 
//  Created by Ben216k on 8/21/24
//  Copyright (c) Ben216k (under 216k License)
//

import SwiftUI
import os

struct SUBridgeOSProduct: SUProductResolved {
    
    let key: String
    let serverMetadataURL: String?
    var packages: [SUPackage]
    let postDate: Date
    let distributions: [String : String]
    var extendedMetaInfo: SUExtendedMetadata?
    var type: SUProductType = .bridgeOS
    var insideCatalogs: [String]
    var serverMetadata: SUServerMetadata?
    var releaseType: SUCatalogType = .release
    var deferredSUEnablementDate: Date?
    var deprecated = false
    
    var basicName: String = "bridgeOS"
    
    var downloadTitleText: String {
        "\(basicName) \(version)"
    }
    var downloadSubtitleText: String { return "For T and M chips" }
    
    var version: String = "N/A"
    var noOverrideVersion: Bool { true }
    
    var image: Image { Image(imageName) }
    var imageName: String { "BridgeOSCircle" }
    
}

// MARK: - Finding the bridge

extension SUBridgeOSProduct {
    
    static func resolve(from product: SUProduct) async -> SUBridgeOSProduct {
        
        var resolved = SUBridgeOSProduct(
            key: product.key,
            serverMetadataURL: product.serverMetadataURL,
            packages: product.packages,
            postDate: product.postDate,
            distributions: product.distributions,
            extendedMetaInfo: product.extendedMetaInfo,
            insideCatalogs: product.insideCatalogs,
            serverMetadata: nil
        )
        
        do {
            guard let distributionURLString = product.distributions["English"] else {
                os_log(
                    "When attempting to process the products, no English distribution was found. Contexts:\n%@",
                    log: LogCategory.swcanReader.osLog, type: .error,
                    "Product: \(product.key)\n"
                )
                throw SWError(source: "SUBridgeOSProduct.resolve()", id: "swerror.reader.noenglishdistribution")
            }

            guard let distributionURL = URL(string: distributionURLString) else {
                os_log(
                    "Somehow, the english distribution URL was invalid. Thanks Apple. Contexts:\n%@",
                    log: LogCategory.swcanReader.osLog, type: .error,
                    "Distribution URL: \(distributionURLString)"
                    + "Product: \(product.key)\n"
                )
                throw SWError(source: "SUBridgeOSProduct.resolve()", id: "swerror.reader.invalidenglishdistributionurl")
            }

            let (data, response) = try await URLSession.shared.data(from: distributionURL)

            guard let httpResponse = response as? HTTPURLResponse else {
                os_log(
                    "When attempting to process the products, the URLSession returned a non-HTTP response (which is horrendously unexpected). Contexts:\n%@",
                    log: LogCategory.swcanReader.osLog, type: .error,
                    "Response Class: \(response.className)\n"
                    + "Response Class Description \(response.classDescription)\n"
                    + "Product: \(product.key)\n"
                    + "Response Description: \(response.description)\n"
                    + "Data as UTF8 String (if possible): \(String(data: data, encoding: .utf8) ?? "It was not possible")"
                )
                throw SWError(source: "SUBridgeOSProduct.resolve()", id: "swerror.reader.nonhttpresponse")
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                os_log(
                    "When attempting to process the products, the URLSession returned a non-HTTP response (which is horrendously unexpected). Contexts:\n%@",
                    log: LogCategory.swcanReader.osLog, type: .error,
                    "HTTP Code: \(httpResponse.statusCode)\n"
                    + "Product: \(product.key)\n"
                    + "Response Description: \(response.description)\n"
                    + "Data as UTF8 String (if possible): \(String(data: data, encoding: .utf8) ?? "It was not possible")"
                )
                throw SWError(source: "SUBridgeOSProduct.resolve()", id: "swerror.reader.standardhttp", data: "\(httpResponse.statusCode)")
            }
            
            guard let utf8String = String(data: data, encoding: .utf8) else {
                os_log(
                    "When attempting to process the products, the distribution data could not be converted to a UTF8 string. Contexts:\n%@",
                    log: LogCategory.swcanReader.osLog, type: .error,
                    "Product: \(product.key)\n"
                )
                throw SWError(source: "SUBridgeOSProduct.resolve()", id: "swerror.reader.utf8conversion")
            }
            
            let pattern = #"<pkg-ref id="com\.apple\.pkg\.BridgeOSUpdateCustomer"[^>]*\bversion="([\d\.]+)""#
            let regex = try NSRegularExpression(pattern: pattern, options: [])
                
            let range = NSRange(utf8String.startIndex..<utf8String.endIndex, in: utf8String)
            if let match = regex.firstMatch(in: utf8String, options: [], range: range) {
                if let versionRange = Range(match.range(at: 1), in: utf8String) {
                    resolved.version = String(utf8String[versionRange])
                    
                } else {
                    throw SWError(source: "SUBridgeOSProduct.resolve()", id: "swerror.reader.versionRangeNil")
                }
            } else {
                throw SWError(source: "SUBridgeOSProduct.resolve()", id: "swerror.reader.regexNoMatch")
            }
        } catch {
            // oh well 👍
            print("no version could be resolved for bridgeOS")
        }
        
        return resolved
    }
    
}
