// 
//  SUCache.swift - Swan
// 
//  Created by Ben216k on 8/3/24
//  Copyright (c) Ben216k (under 216k License)
// 

import Foundation
import SwiftUI
import os
import Combine

@MainActor
final class SUCache: ObservableObject {
    
    static let shared = SUCache()
    
    @Published var hasSetCaches = false
    @Published var lifeSucks: SWError?
    @Published var catalogs: [String: SUCatalog] = [:]
    @Published var products: [String: any SUProductResolved] = [:]
    @Published var usedCatalogs: [SUCatalogSource] = SUCatalogSource.bestKnownCatalogs
    @Published var rejectedProducts: [(product: SUProduct, error: SWError)] = []
    @Published var showTableFooter: Bool = false
    @Published var showUnformattedName: Bool = false
    @Published var showProductIcons: Bool = false
    private var cancellables = Set<AnyCancellable>()
    @Published var sidebarOptions: [String: Bool] = [:]
    
    // MARK: Sidebar Stuff
    
    static let defaultSidebarOptions: [String: Bool] = [
        "All": true,
        "macOS": true,
        "CLTools": true,
        "bridgeOS": true,
        "BootCamp": true,
        "Safari": true,
        "Voices": true,
        "SecUpd": true,
        "Beats": false,
        "DeviceSupport": false,
        "iTunes": false,
        "ProVideo": false,
        "LogicPro": false,
        "SFSymbols": false,
        "Unknown": false
    ]
    
    // MARK: BREAK
    private func synchronizeWithUserDefaults() {
        let userDefaultConfigs: [(key: String, defaultValue: Bool, keyPath: ReferenceWritableKeyPath<SUCache, Bool>)] = [
            ("showTableFooter", false, \.showTableFooter),
            ("showUnformattedName", false, \.showUnformattedName),
            ("showProductIcons", true, \.showProductIcons)
        ]

        for config in userDefaultConfigs {
            // Initialize property from UserDefaults or use default value
            let storedValue = UserDefaults.standard.object(forKey: config.key) as? Bool
            self[keyPath: config.keyPath] = storedValue ?? config.defaultValue

            // Set up a subscriber to update UserDefaults when the property changes
            // Access the publisher using dynamic key paths is not straightforward, so we handle each property separately
            switch config.keyPath {
            case \.showTableFooter:
                self.$showTableFooter
                    .sink { newValue in
                        UserDefaults.standard.set(newValue, forKey: config.key)
                    }
                    .store(in: &cancellables)
            case \.showUnformattedName:
                self.$showUnformattedName
                    .sink { newValue in
                        UserDefaults.standard.set(newValue, forKey: config.key)
                    }
                    .store(in: &cancellables)
            case \.showProductIcons:
                self.$showProductIcons
                    .sink { newValue in
                        UserDefaults.standard.set(newValue, forKey: config.key)
                    }
                    .store(in: &cancellables)
            default:
                break
            }
        }
    }
    
    @Published var ipswReleases: [IPSWRelease] = []
    
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
        synchronizeWithUserDefaults()
        loadSidebarOptions()
        
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
    
    @Published var ipswSortOrder = [KeyPathComparator(\IPSWRelease.postDateForSorting, order: .reverse)]
    @Published var ipswSearch = ""
    var ipsws: [IPSWRelease] {
        ipswReleases.filter{
            let search = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return search.isEmpty
            || $0.version.starts(with: search)
            || $0.name.lowercased().contains(search)
            || $0.buildNumber.lowercased().contains(search)
        }.sorted(using: ipswSortOrder)
    }
    
    // MARK: - Sidebar Options Management
    private func loadSidebarOptions() {
        if let stored = UserDefaults.standard.dictionary(forKey: "sidebarOptions") as? [String: Bool] {
            // Merge stored options with defaults to include any new sidebar IDs
            var merged = SUCache.defaultSidebarOptions
            for (key, value) in stored {
                merged[key] = value
            }
            self.sidebarOptions = merged
        } else {
            self.sidebarOptions = SUCache.defaultSidebarOptions
        }
        
        $sidebarOptions
            .sink { newOptions in
                UserDefaults.standard.set(newOptions, forKey: "sidebarOptions")
            }
            .store(in: &cancellables)
    }
    
    /// Checks if a sidebar option is enabled.
    /// - Parameter id: The unique identifier for the sidebar option.
    /// - Returns: `true` if enabled, `false` otherwise.
    func isSidebarOptionEnabled(id: String) -> Bool {
        return sidebarOptions[id] ?? SUCache.defaultSidebarOptions[id] ?? false
    }
    
    /// Provides a Binding for a sidebar option's enabled state.
    /// - Parameter id: The unique identifier for the sidebar option.
    /// - Returns: A `Binding<Bool>` representing the option's enabled state.
    func bindingForSidebarOption(id: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.isSidebarOptionEnabled(id: id) },
            set: { newValue in
                self.sidebarOptions[id] = newValue
            }
        )
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
