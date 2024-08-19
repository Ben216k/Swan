// 
//  SUCache.swift - Swan
// 
//  Created by Ben216k on 8/3/24
//  Copyright (c) Ben216k (under 216k License)
// 

import Foundation

@MainActor
final class SUCache: ObservableObject {
    
    static let shared = SUCache()
    
    @Published var hasSetCaches = false
    @Published var lifeSucks: SWError?
    @Published var catalogs: [String: SUCatalog] = [:]
    @Published var products: [String: any SUProductResolved] = [:]
    @Published var usedCatalogs: [SUCatalogSource] = SUCatalogSource.bestKnownCatalogs
    @Published var rejectedProducts: [(product: SUProduct, error: SWError)] = []
    
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
    
    @Published var macOSpackagesSortOrder = [KeyPathComparator(\SUMacOSPackage.buildNumber, order: .reverse)]
    @Published var macOSpackagesSearch = ""
    var macOSpackages: [SUMacOSPackage] {
        products.values.compactMap { $0 as? SUMacOSPackage }.filter{
            let search = macOSpackagesSearch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return search.isEmpty
            || $0.osName.lowercased().starts(with: search)
            || $0.version.starts(with: search)
            || $0.buildNumber.lowercased().starts(with: search)
            || $0.key.lowercased().starts(with: search)
            || String(localized: $0.releaseType.name).lowercased().contains(search)
        }.sorted(using: macOSpackagesSortOrder)
    }

    @Published var safariSortOrder = [KeyPathComparator(\SUSafariResolved.version, order: .reverse)]
    @Published var safariSearch = ""
    var safariPackages: [SUSafariResolved] {
        products.values.compactMap { $0 as? SUSafariResolved }.filter{
            let search = safariSearch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return search.isEmpty
            || $0.version.lowercased().starts(with: search)
            || $0.key.lowercased().starts(with: search)
            || $0.macOSVersion.lowercased().starts(with: search)
            || String(localized: $0.releaseType.name).lowercased().contains(search)
        }.sorted(using: safariSortOrder)
    }
    
}
