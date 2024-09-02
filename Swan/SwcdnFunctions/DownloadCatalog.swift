// 
//  DownloadCatalog.swift - Swan
// 
//  Created by Ben216k on 8/3/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import os

extension SUCatalogSource {
    func download() async throws(SWError) -> SUCatalog {
        do {
            let (data, response) = try await URLSession.shared.data(from: self.url)
            
            // Ensure the response is an HTTP response and check the status code
            guard let httpResponse = response as? HTTPURLResponse else {
                os_log(
                    "When attempting to read the catalog, the URLSession returned a non-HTTP response (which is horrendously unexpected). Contexts:\n%@",
                    log: LogCategory.swcanReader.osLog, type: .error,
//                    "Response Class: \(response.className)\n"
//                    "Response Class Description: \(response.classDescription)\n"
                    "Catalog URL: \(self.url.absoluteString)\n"
                    + "Catalog ID: \(self.id)\n"
                    + "Response Description: \(response.description)"
                    + "Data as UTF8 String (if possible): \(String(data: data, encoding: .utf8) ?? "It was not possible")"
                )
                throw SWError(source: "SwcanReader.readCatalog()", id: "swerror.reader.nonhttpresponse")
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                os_log(
                    "When attempting to read the catalog, the URLSession returned a non-HTTP response (which is horrendously unexpected). Contexts:\n%@",
                    log: LogCategory.swcanReader.osLog, type: .error,
                    "HTTP Code: \(httpResponse.statusCode)\n"
                    + "Catalog URL: \(self.url.absoluteString)\n"
                    + "Catalog ID: \(self.id)\n"
                    + "Response Description: \(response.description)\n"
                    + "Data as UTF8 String (if possible): \(String(data: data, encoding: .utf8) ?? "It was not possible")"
                )
                throw SWError(source: "SwcanReader.readCatalog()", id: "swerror.reader.standardhttp", data: "\(httpResponse.statusCode)")
            }
            
            // Create shell then compile into full catalog use plists
            let shell = try PropertyListDecoder().decode(SUCatalogShell.self, from: data)
            var catalog = SUCatalog(from: shell, source: self)
            
            // Iterrate through all products and get their key lol
            for key in catalog.products.keys {
                catalog.products[key]?._key = key
            }
            
            // Update the cache
            await SUCache.shared.setCatalog(id, catalog: catalog)
            
            return catalog
        } catch {
            if let error = error as? SWError {
                throw error
            }
            os_log(
                "When attempting to read the catalog, an error occurred. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Catalog URL: \(self.url.absoluteString)\n"
                + "Catalog ID: \(self.id)\n"
                + "Error Localized Description: \(error.localizedDescription)\n"
                + "Error idk: \(error)"
            )
            throw SWError(source: "SwcanReader.readCatalog()", id: "swerror.foundation.unknown", customText: error.localizedDescription)
        }
    }
}

// MARK: SUCache handlers

extension SUCache {
    func downloadUsedCatalogs() async throws(SWError) {
        self.clearCatalogs()
        
        var newCatalogs: [SUCatalog] = []
        do {
            newCatalogs = try await withThrowingTaskGroup(of: SUCatalog.self) { group in
                for source in SUCache.shared.usedCatalogs {
                    group.addTask {
                        return try await source.download()
                    }
                }
                
                var theseCatalogs: [SUCatalog] = []
                while let catalog = try await group.next() {
                    theseCatalogs.append(catalog)
                }
                return theseCatalogs
            }
        } catch {
            if let error = error as? SWError {
                throw error
            }
            os_log(
                "When attempting to donwload used catalog, an error occurred. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Error Localized Description: \(error.localizedDescription)\n"
                + "Error idk: \(error)"
            )
            throw SWError(source: "SUCache.downloadUsedCatalogs()", id: "swerror.foundation.unknown", customText: error.localizedDescription)
        }
        
        var uniqueProducts: [String: SUProduct] = [:]
        
        for catalog in newCatalogs {
            for (key, product) in catalog.products {
                if uniqueProducts[key] != nil {
                    uniqueProducts[key]?._insideCatalogs?.append(catalog.id)
                    continue
                }
                uniqueProducts[key] = product
                uniqueProducts[key]?._insideCatalogs = [catalog.id]
            }
        }
        
        var processedProducts: [String: any SUProductResolved] = [:]
        await withTaskGroup(of: (any SUProductResolved)?.self) { group in
            for (_, product) in uniqueProducts {
                group.addTask {
                    return await product.resolve()
                }
            }
            
            var resolved: [String: (any SUProductResolved)] = [:]
            while let product = await group.next() {
                guard let product = product else { continue }
                resolved[product.key] = product
            }
            processedProducts = resolved
            
        }
        
        do {
            let fileManager = FileManager.default
            let cachedFileNames = try fileManager.contentsOfDirectory(atPath: cacheDirectoryURL.path)
                .filter { $0.hasSuffix(".json") }
                .map { $0.replacingOccurrences(of: ".json", with: "") }

            let deprecatedKeys = Set(cachedFileNames).subtracting(processedProducts.keys)
            
            print(deprecatedKeys)

            for deprecatedKey in deprecatedKeys {
                // Load the deprecated product from the cache
                guard let data = try? Data(contentsOf: cacheURL(forKey: deprecatedKey)) else { continue }

                // 1. Decode only the product type
                guard let typeWrapper = try? JSONDecoder().decode(ProductTypeWrapper.self, from: data) else { continue }

                var resolvedProduct: (any SUProductResolved)?

                // 2. Decode based on the specific product type
                switch typeWrapper.type {
                case .macOSpackage:
                    resolvedProduct = try? JSONDecoder().decode(SUMacOSPackage.self, from: data)
                case .safari:
                    resolvedProduct = try? JSONDecoder().decode(SUSafariResolved.self, from: data)
                case .bridgeOS:
                    resolvedProduct = try? JSONDecoder().decode(SUBridgeOSProduct.self, from: data)
                case .securityupdate:
                    resolvedProduct = try? JSONDecoder().decode(SUSecurityUpdateResolved.self, from: data)
                case .cltools:
                    resolvedProduct = try? JSONDecoder().decode(SUCLToolsResolved.self, from: data)
                case .voiceupdate:
                    resolvedProduct = try? JSONDecoder().decode(SUVoiceUpdateResolved.self, from: data)
                case .unknown, .sfsymbols, .bootcamp, .provideoformat, .devicesupport, .itunes, .beats, .logicpro:
                    resolvedProduct = try? JSONDecoder().decode(SUUnresolvedProduct.self, from: data)
                }

                // 3. Mark as deprecated and update the products dictionary
                if var resolvedProduct {
                    print("made it here with \(resolvedProduct.key)")
                    resolvedProduct.deprecated = true
                    processedProducts[resolvedProduct.key] = processedProducts[resolvedProduct.key] ?? resolvedProduct
                }
            }

        } catch {
            // ... (Your error handling code) ...
        }

        self.products = processedProducts
    }
}
