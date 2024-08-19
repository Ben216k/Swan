// 
//  SwanTests.swift - SwanTests
// 
//  Created by Ben216k on 8/3/24
//  Copyright (c) Ben216k (under 216k License)
// 

import Testing
@testable import Swan
import Foundation

struct SwanTests {

    @Test func verifyHardcodedCatalogs() async throws {
        
        // Check if the hardcoded catalogs are correct. Basically take the url and check if the ID, name, and type are correct
        // index-(.*?)- to get the ID from the URL
        // Use SUCatalogSource.allKnownCatalogs to get all the hardcoded catalogs

        let allCatalogs = SUCatalogSource.allKnownCatalogs

        for catalog in allCatalogs {
            let url = catalog.url
            let id = catalog.id
            let name = catalog.name
            let type = catalog.type

            let idRegex = try NSRegularExpression(pattern: "index-(.*?)-")
            let idMatch = idRegex.firstMatch(in: url.absoluteString, range: NSRange(location: 0, length: url.absoluteString.count))

            guard let idRange = idMatch?.range(at: 1) else {
                #expect(Bool(false), "Could not find ID in URL. \(name)")
                continue
            }

            let urlID = String(url.absoluteString[Range(idRange, in: url.absoluteString)!])
            
            if id.contains("11") {
                #expect(urlID == id.replacingOccurrences(of: "11", with: "10.16"), "ID mismatch for \(name): \(urlID) != \(id.replacingOccurrences(of: "11", with: "10.16"))")
            } else {
                #expect(urlID == id, "ID mismatch for \(name): \(urlID) != \(id)")
            }

            // Get the version number from the ID (remove seed/beta if it's there)
            // We don't need regex for this

            if urlID.contains("seed") {
               #expect(type == .seed, "Type mismatch for \(name): \(type) != seed")
            } else if urlID.contains("beta") {
                #expect(type == .beta, "Type mismatch for \(name): \(type) != beta")
            } else {
                #expect(type == .release, "Type mismatch for \(name): \(type) != release")
            }

            var version = urlID.replacingOccurrences(of: "seed", with: "").replacingOccurrences(of: "beta", with: "")
            if version == "10.16" {
                version = "11"
            }

            #expect(name.contains(version), "Version mismatch for \(name): \(version) not in \(name)")

            let versionInt = Int(version.replacingOccurrences(of: ".", with: ""))
            #expect(versionInt != nil, "Version is not a number for \(name): \(version)")

            // Reconstruction of the name, lovely SUMacOSPackage.osName(_:) can get us the version name, ex "macOS 13 Ventura Public Beta"

            let osName = SUMacOSPackage.osName(for: versionInt!)
            #expect(name.contains(osName), "Version name mismatch for \(name): \(osName) not in \(name)")

            switch type {
            case .seed:
                #expect("macOS \(version) \(osName) Developer Beta" == name, "Name mismatch for \(name): \(name) != macOS \(version) \(osName) Developer Beta")
            case .beta:
                #expect("macOS \(version) \(osName) Public Beta" == name, "Name mismatch for \(name): \(name) != macOS \(version) \(osName) Public Beta")
            case .release:
                #expect("macOS \(version) \(osName)" == name, "Name mismatch for \(name): \(name) != macOS \(version) \(osName)")
            }

            // Yay, that one was fine.
            
        }

    }

    @Test func processCatalog() async throws {

        let catalog = try await SUCatalogSource.sequoiaSeed.resolved
        
        #expect(catalog.name == "macOS 15 Sequoia Developer Beta", "Name mismatch for catalog: \(catalog.name)")
        #expect(catalog.type == .seed, "Type mismatch for catalog: \(catalog.type)")
        #expect(catalog.id == "15seed", "ID mismatch for catalog: \(catalog.id)")
        #expect(catalog.catalogVersion == 2, "Catalog version mismatch for catalog: \(catalog.catalogVersion). Check for updates.")
        
        var resolvedProducts: [any SUProductResolved] = []
        for (_, product) in catalog.products {
            if let item = try? await product.resolve() {
                resolvedProducts.append(item)
            }
        }

        #expect(resolvedProducts.count > 0, "No products resolved in catalog")

        let macOSPackagesResolved = resolvedProducts.filter { $0.type == .macOSpackage }
        #expect(macOSPackagesResolved.count > 0, "No macOS packages resolved in catalog")

        let macOSPackages = macOSPackagesResolved.compactMap { $0 as? SUMacOSPackage }.sorted { $0.version > $1.version }
        #expect(macOSPackages.count == macOSPackagesResolved.count, "Not all macOS packages resolved correctly")

        let bigSur = macOSPackages.first { $0.buildNumber == "20G1427" }
        #expect(bigSur != nil, "Big Sur not found")
        #expect(bigSur!.majorVersion == 11, "Big Sur major version mismatch")
        #expect(bigSur!.packages.contains { $0.url.hasSuffix("InstallAssistant.pkg") }, "Big Sur InstallAssistant not found")
        #expect(bigSur!.version == "11.7.10", "Big Sur version mismatch")
        #expect(bigSur!.key != "\(bigSur!.postDate)", "Key defaulted.")

        let catalina = macOSPackages.first { $0.buildNumber == "19H15" }
        #expect(catalina != nil, "Catalina not found")
        #expect(catalina!.majorVersion == 1015, "Catalina major version mismatch")
        #expect(catalina!.packages.contains { $0.url.hasSuffix("InstallAssistantAuto.pkg") }, "Catalina InstallAssistantAuto not found")
        #expect(catalina!.version == "10.15.7", "Catalina version mismatch")
        #expect(catalina!.key != "\(catalina!.postDate)", "Key defaulted.")

        // print all macos package versions
        print(macOSPackages.map { $0.version })


    }

    @Test func fullCatalogScan() async throws {
        // This checks all (best known) catalogs, not as deep as processCatalog, but checks if they're all there and can be resolved.
        try await SUCache.shared.downloadUsedCatalogs()

        // make sure best known length is the same as the updated cache
        await #expect(SUCache.shared.usedCatalogs.count == SUCatalogSource.bestKnownCatalogs.count, "Best known catalogs length mismatch")

        for source in await SUCache.shared.usedCatalogs {
            let catalog = try await source.resolved
            #expect(catalog != nil, "Catalog not resolved")
        }

        // make sure there are products in the cache
        #expect(await SUCache.shared.products.count > 0, "No products in cache")
        
        for product in await SUCache.shared.products {
            #expect(product.key == product.value.key, "Key mismatch.")
        }

        // ensure a product with a full installer exists
        let macOSPackages = await SUCache.shared.products.compactMap { $0.value as? SUMacOSPackage }
        let fullInstallers = macOSPackages.filter { $0.packages.contains { $0.url.hasSuffix("InstallAssistant.pkg") } }
        #expect(fullInstallers.count > 0, "No full installers found")

        // ensure a product with an auto installer exists
        let autoInstallers = macOSPackages.filter { $0.packages.contains { $0.url.hasSuffix("InstallAssistantAuto.pkg") } }
        #expect(autoInstallers.count > 0, "No auto installers found")

        // ensure a product with a safari package exists
        let safariProducts = await SUCache.shared.products.compactMap { $0.value as? SUSafariResolved }
        #expect(safariProducts.count > 0, "No safari products resolved")
        // let safariProduct = safariProducts.first
        // #expect(safariProduct.count > 0, "No safari products found")
        // #expect(safariProduct.serverMetadataURL?.contains("Safari") == true, "Safari not in serverMetadataURL")
        // #expect(safariProduct.serverMetadataURL?.contains(safariProduct.version) == true, "Safari version not in serverMetadataURL")
        // #expect(safariProduct.serverMetadataURL?.contains(safariProduct.macOSVersion) == true, "macOS version not in serverMetadataURL")
        // // for 

        for product in safariProducts {
            #expect(product.serverMetadataURL?.contains("Safari") == true, "Safari not in serverMetadataURL")
            #expect(product.serverMetadataURL?.contains(product.version) == true, "Safari version not in serverMetadataURL")
            #expect(product.serverMetadataURL?.contains(product.macOSVersion) == true, "macOS version not in serverMetadataURL")
            guard let serverMetadataURL = URL(string: product.serverMetadataURL!) else {
                #expect(Bool(false), "Could not create URL from serverMetadataURL")
                continue
            }
            #expect(product.packages.contains { $0.url.contains(serverMetadataURL.lastPathComponent.replacingOccurrences(of: "smd", with: "pkg")) }, "Safari package not in packages???")
        }
    }

}
