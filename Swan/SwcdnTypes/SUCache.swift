// 
//  SUCache.swift - Swan
// 
//  Created by Ben216k on 8/3/24
//  Copyright (c) Ben216k (under 216k License)
// 

import Foundation
import os

@MainActor
final class SUCache: ObservableObject {
    
    static let shared = SUCache()
    
    @Published var hasSetCaches = false
    @Published var lifeSucks: SWError?
    @Published var catalogs: [String: SUCatalog] = [:]
    @Published var products: [String: any SUProductResolved] = [:]
    @Published var usedCatalogs: [SUCatalogSource] = SUCatalogSource.bestKnownCatalogs
    @Published var rejectedProducts: [(product: SUProduct, error: SWError)] = []
    @Published var showTableFooter = false
    @Published var showUnformattedName = false
    
    func setCatalog(_ id: String, catalog: SUCatalog) {
        self.catalogs[id] = catalog
    }
    
    func getCatalog(_ id: String) -> SUCatalog? {
        self.catalogs[id]
    }

    func clearCatalogs() {
        self.hasSetCaches = false
        self.lifeSucks = nil
        self.catalogs = [:]
        self.products = [:]
        self.rejectedProducts = []
    }
    
    init() {
        Task {
            await self.beginFillingCache()
        }
    }
    
    @Published var everythingSortOrder = [KeyPathComparator(\SUFakedResolved.postDateForSorting, order: .reverse)]
    @Published var search = ""
    var everythingProduts: [SUFakedResolved] {
        products.values.map { SUFakedResolved($0) }.filter{
            let search = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return search.isEmpty
            || $0.version.starts(with: search)
            || $0.basicName.lowercased().contains(search)
            || $0.unformattedName.lowercased().contains(search)
            || $0.key.lowercased().starts(with: search)
            || String(localized: $0.releaseType.name).lowercased().contains(search)
        }.sorted(using: everythingSortOrder)
    }
    
    @Published var macOSpackagesSortOrder = [KeyPathComparator(\SUMacOSPackage.buildNumber, order: .reverse)]
    var macOSpackages: [SUMacOSPackage] {
        products.values.compactMap { $0 as? SUMacOSPackage }.filter{
            let search = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return search.isEmpty
            || $0.osName.lowercased().starts(with: search)
            || $0.version.starts(with: search)
            || $0.buildNumber.lowercased().starts(with: search)
            || $0.key.lowercased().starts(with: search)
            || String(localized: $0.releaseType.name).lowercased().contains(search)
        }.sorted(using: macOSpackagesSortOrder)
    }

    @Published var safariSortOrder = [KeyPathComparator(\SUSafariResolved.version, order: .reverse)]
    var safariPackages: [SUSafariResolved] {
        products.values.compactMap { $0 as? SUSafariResolved }.filter{
            let search = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return search.isEmpty
            || $0.basicName.lowercased().contains(search)
            || $0.version.lowercased().starts(with: search)
            || $0.key.lowercased().starts(with: search)
            || $0.macOSVersion.lowercased().starts(with: search)
            || String(localized: $0.releaseType.name).lowercased().contains(search)
        }.sorted(using: safariSortOrder)
    }
    
}

extension SUCache {
    func storeResolvedProduct(_ product: any SUProductResolved) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(product)
        try storeProductData(data, forKey: product.key)
    }

    private func storeProductData(_ data: Data, forKey key: String) throws {
        let cacheURL = cacheDirectoryURL.appendingPathComponent(key + ".json")
        try data.write(to: cacheURL)
    }

    var cacheDirectoryURL: URL {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let swanCacheURL = cacheDirectory.appendingPathComponent("Swan")

        // Create the Swan cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: swanCacheURL.path) {
            try? fileManager.createDirectory(at: swanCacheURL, withIntermediateDirectories: true)
        }
        
        return swanCacheURL
    }
    
    func cacheURL(forKey key: String) -> URL {
        cacheDirectoryURL.appendingPathComponent(key + ".json")
    }
    
    func clearCache() {
        do {
            let fileManager = FileManager.default
            let cacheDirectory = cacheDirectoryURL
            let files = try fileManager.contentsOfDirectory(atPath: cacheDirectory.path)
            for file in files {
                let fileURL = cacheDirectory.appendingPathComponent(file)
                try fileManager.removeItem(at: fileURL)
            }
            os_log("Cache cleared successfully.", log: LogCategory.mainCode.osLog, type: .info)
        } catch {
            os_log("Error clearing cache: %@", log: LogCategory.mainCode.osLog, type: .error, error.localizedDescription)
            // You might want to present an error to the user here.
        }
    }
    
    func clearUnknownCache() {
            do {
                let fileManager = FileManager.default
                let cacheDirectory = cacheDirectoryURL
                let files = try fileManager.contentsOfDirectory(atPath: cacheDirectory.path)

                for file in files where file.hasSuffix(".json") {
                    let fileURL = cacheDirectory.appendingPathComponent(file)
                    let data = try Data(contentsOf: fileURL)

                    // Decode only the product type
                    guard let typeWrapper = try? JSONDecoder().decode(ProductTypeWrapper.self, from: data),
                          typeWrapper.type == .unknown else { continue }

                    // Delete the cached file for unknown products
                    try fileManager.removeItem(at: fileURL)
                }

                os_log("Unknown product cache cleared successfully.", log: LogCategory.mainCode.osLog, type: .info)

                // Reload the SUCache (you'll need to implement this)
                Task {
                    await self.beginFillingCache()
                }

            } catch {
                os_log("Error clearing unknown product cache: %@", log: LogCategory.mainCode.osLog, type: .error, error.localizedDescription)
                // Handle the error (e.g., present an alert to the user)
            }
        }
}
