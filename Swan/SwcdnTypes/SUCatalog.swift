//
//  SUCatalog.swift - Swan
//
//  Created by Ben216k on 7/30/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import os

// MARK: - SUCatalogSource

/// Basic information about a Software Update Catalog, before downloading the full catalog
struct SUCatalogSource: Codable, Identifiable, Sendable {
    
    /// Full URL of the catalog
    let url: URL
    /// The name of the catalog (e.g. macOS 15 Sequoia Developer Beta, macOS 11 Big Sur Releases)
    let name: String
    /// The type of the catalog (e.g. seed, beta, release)
    let type: SUCatalogType
    /// The identifier of the catalog (eg. 15seed, 12beta, 11)
    let id: String

    var resolved: SUCatalog { get async throws(SWError) {
        if let catalog = await SUCache.shared.getCatalog(id) {
            return catalog
        } else {
            return try await self.download()
        }
    }}

}


// MARK: - SUCatalog

/// A Software Update Catalog, fully downloaded and parsed
struct SUCatalog: Identifiable, Sendable {
    
    /// Full URL of the catalog
    let url: URL
    /// The name of the catalog (e.g. macOS 15 Sequoia Developer Beta, macOS 11 Big Sur Releases)
    let name: String
    /// The type of the catalog (e.g. seed, beta, release)
    let type: SUCatalogType
    /// The identifier of the catalog (eg. 15seed, 12beta, 11)
    let id: String
    
    /// Catalog version, probably `2`.
    let catalogVersion: Int

    /// Apple Post URL, empty in the current catalogs
    let applePostURL: String?

    /// Index Date, the date when the catalog was last updated
    let indexDate: Date

    /// Products in the catalog
    var products: [String: SUProduct]

    enum CodingKeys: String, CodingKey {
        case catalogVersion = "CatalogVersion"
        case applePostURL = "ApplePostURL"
        case indexDate = "IndexDate"
        case products = "Products"

        // THESE WILL NEVER BE ON THE CATALOG
        case url = "UNUSED_URL"
        case name = "UNUSED_NAME"
        case type = "UNUSED_TYPE"
        case id = "UNUSED_ID"
    }
}

extension SUCatalog {
    internal init(from shell: SUCatalogShell, source: SUCatalogSource) {
        self.url = source.url
        self.name = source.name
        self.type = source.type
        self.id = source.id
        self.catalogVersion = shell.catalogVersion
        self.applePostURL = shell.applePostURL
        self.indexDate = shell.indexDate
        self.products = shell.products
    }
}

/// Shell for SUCatalog, doesn't contain information linked to the catalog source
internal struct SUCatalogShell: Codable {
    let catalogVersion: Int
    let applePostURL: String?
    let indexDate: Date
    let products: [String: SUProduct]

    enum CodingKeys: String, CodingKey {
        case catalogVersion = "CatalogVersion"
        case applePostURL = "ApplePostURL"
        case indexDate = "IndexDate"
        case products = "Products"
    }
}

// MARK: - SUProduct

/// A product in the SUCatalog
struct SUProduct: Codable, Sendable {
    
    var _key: String?
    var _insideCatalogs: [String]?

    /// Server Metadata URL
    let serverMetadataURL: String?

    /// Packages in the product
    let packages: [SUPackage]

    /// Post Date
    let postDate: Date

    /// Distributions in the product, yay!
    /// BE CAREFUL: The key is the locale, which is sometimes `zh_TW` and sometimes `English`, and it's usually the same for each language, but still goofy.
    let distributions: [String: String]

    /// ExtendedMetaInfo, yes it's a cursed type, but it's just a dictionary of dictionaries
    /// InstallAssistantPackageIdentifiers is the only one I've ever seen.
    let extendedMetaInfo: SUExtendedMetadata?

    /// Deferred SU Enablement Date, no idea what this is
    let deferredSUEnablementDate: Date?

    /// State, only seen `ramped` afaik
    let state: String?

    enum CodingKeys: String, CodingKey {
        /// Key will never be found
        case _key = "UNUSED_KEY"
        case _insideCatalogs = "UNUSED_INSIDE_CATALOGS"
        case serverMetadataURL = "ServerMetadataURL"
        case packages = "Packages"
        case postDate = "PostDate"
        case distributions = "Distributions"
        case extendedMetaInfo = "ExtendedMetaInfo"
        case deferredSUEnablementDate = "DeferredSUEnablementDate"
        case state = "State"
    }
    
    var key: String {
        _key ?? "\(postDate)"
    }

    var insideCatalogs: [String] {
        _insideCatalogs ?? []
    }

}

// MARK: - SUPackage

/// A package in the SUProduct
struct SUPackage: Codable, Sendable, Identifiable {
    /// Size, probably in kilobytes
    let size: Int
    let integrityDataSize: Int?

    /// Main URL, there's sometimes others
    let url: String

    let digest: String?

    let metadataURL: String?
    let integrityDataURL: String?

    /// URL, but just the last path component (e.g. `InstallAssistant.pkg`)
    var name: String {
        URL(string: url)?.lastPathComponent ?? "Unknown"
    }
    
    var id: String { url }
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    var formattedIntegritySize: String? {
        guard let integrityDataSize else { return nil }
        return ByteCountFormatter.string(fromByteCount: Int64(integrityDataSize), countStyle: .file)
    }

    enum CodingKeys: String, CodingKey {
        case size = "Size"
        case integrityDataSize = "IntegrityDataSize"
        case url = "URL"
        case digest = "Digest"
        case metadataURL = "MetadataURL"
        case integrityDataURL = "IntegrityDataURL"
    }
}

// MARK: - SUExtendedMetadata

struct SUExtendedMetadata: Codable, Sendable {
    let productType: String?
    let productVersion: String?
    let autoUpdate: String?
    let bridgeOSPredicateProductOrdering: String?
    let bridgeOSSoftwareUpdateEventRecordingServiceURL: String?
    let installAssistantPackageIdentifiers: SUInstallAssistantPackageIdentifiers?

    enum CodingKeys: String, CodingKey {
        case productType = "ProductType"
        case productVersion = "ProductVersion"
        case autoUpdate = "AutoUpdate"
        case bridgeOSPredicateProductOrdering = "BridgeOSPredicateProductOrdering"
        case bridgeOSSoftwareUpdateEventRecordingServiceURL = "BridgeOSSoftwareUpdateEventRecordingServiceURL"
        case installAssistantPackageIdentifiers = "InstallAssistantPackageIdentifiers"
    }

    var containsAnythingButInstallAssistant: Bool {
        productType != nil || productVersion != nil || autoUpdate != nil || bridgeOSPredicateProductOrdering != nil || bridgeOSSoftwareUpdateEventRecordingServiceURL != nil
    }
}

struct SUInstallAssistantPackageIdentifiers: Codable, Sendable {
    let installInfo: String?
    let osInstall: String?
    let sharedSupport: String?
    let info: String?
    let updateBrain: String?
    let buildManifest: String?

    enum CodingKeys: String, CodingKey {
        case installInfo = "InstallInfo"
        case osInstall = "OSInstall"
        case sharedSupport = "SharedSupport"
        case info = "Info"
        case updateBrain = "UpdateBrain"
        case buildManifest = "BuildManifest"
    }
}


// MARK: - SUCatalogType

/// The type of the catalog
enum SUCatalogType: String, Codable, Sendable {
    /// Developer Beta seed releases
    case seed
    /// Public Beta releases
    case beta
    /// General Releases
    case release

    /// The name of the type
    var name: LocalizedStringResource {
        switch self {
        case .seed:
            return "sucatalog.type.seed"
        case .beta:
            return "sucatalog.type.beta"
        case .release:
            return "sucatalog.type.release"
        }
    }
}

// Extend SUPackage to find biggest package and the lastPathComponent of the URL
extension Array where Element == SUPackage {
    var biggestPackage: SUPackage? {
        self.max { $0.size < $1.size }
    }
    var biggestPackageSize: Int {
        biggestPackage?.size ?? 0
    }
    var biggestPackageName: String? {
        // make url from string
        guard let url = biggestPackage?.url else { return nil }
        return URL(string: url)?.lastPathComponent
    }
}