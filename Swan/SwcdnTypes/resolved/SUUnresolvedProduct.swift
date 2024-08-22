// 
//  SUUnresolvedProduct.swift - Swan
// 
//  Created by Ben216k on 8/20/24
//  Copyright (c) Ben216k (under 216k License)
// 

import Foundation
import SwiftUI

struct SUUnresolvedProduct: SUProductResolved {
    
    let key: String
    let serverMetadataURL: String?
    var packages: [SUPackage]
    let postDate: Date
    let distributions: [String : String]
    var extendedMetaInfo: SUExtendedMetadata?
    var type: SUProductType = .unknown
    var insideCatalogs: [String]
    var serverMetadata: SUServerMetadata?
    var releaseType: SUCatalogType = .release
    var deferredSUEnablementDate: Date?
    var deprecated = false
    
    var basicName: String {
        if let serverMetadataURL, serverMetadataURL.contains("BootCamp") {
            let baseName = "Boot Camp"
            return serverMetadataURL.contains("ESD") ? "\(baseName) ESD" : baseName
        } else {
            return serverMetadata?.localizations["English"]?.title ?? serverMetadataURL?.urlLastPathCompenent?.replacingOccurrences(of: ".smd", with: "") ?? packages.biggestPackageName ?? "Unknown Product"
        }
    }
    
    var downloadTitleText: String {
        "\(basicName) \(version)"
    }
    var downloadSubtitleText: String { return "" }
    
    var version: String = "N/A"
    
    var image: Image { Image(imageName) }
    var imageName: String {
        if let serverMetadataURL, serverMetadataURL.contains("SFSymbols") {
            return "SFSymbolsCircle"
        } else if let serverMetadataURL, serverMetadataURL.contains("ProVideoFormats") {
            return "ProViewFormatsCircle"
        } else if let serverMetadataURL, serverMetadataURL.contains("BootCamp") {
            return "BootcampCircle"
        } else {
            return "UnknownProductCircle"
        }
    }
    
}

// MARK: - Resolving the unknown product!

extension SUUnresolvedProduct {
    
    static func resolve(from product: SUProduct) async -> SUUnresolvedProduct {
        return SUUnresolvedProduct(
            key: product.key,
            serverMetadataURL: product.serverMetadataURL,
            packages: product.packages,
            postDate: product.postDate,
            distributions: product.distributions,
            extendedMetaInfo: product.extendedMetaInfo,
            insideCatalogs: product.insideCatalogs,
            serverMetadata: nil
        )
    }
    
}

extension String {
    var urlLastPathCompenent: String? {
        return URL(string: self)?.lastPathComponent
    }
}
