// 
//  SUMacOSPackage.swift - Swan
//
//  Created by Ben216k on 7/31/24
//  Copyright (c) Ben216k (under 216k License)
// 

import Foundation
import os
import SwiftUI

// MARK: - SUMacOSPackage

struct SUMacOSPackage: SUProductResolved {

    // In the actual thing lol
    let key: String
    let serverMetadataURL: String?
    var serverMetadata: SUServerMetadata?
    var packages: [SUPackage]
    let postDate: Date
    let distributions: [String: String]
    let extendedMetaInfo: SUExtendedMetadata?
    let type: SUProductType = .macOSpackage

    // HAVE TO FETCH FROM A SECOND LINK (in the distrubutions, just check English, cause they're all the same and the others aren't always there)
    let version: String
    let buildNumber: String
    /// The major version of the macOS release
    /// - Note: Versions prior to 11 have a major version of 10XX where XX is the minor, but technically major, version (e.g. 10.15 is 1015)
    let majorVersion: Int

    let insideCatalogs: [String] 
    var releaseType: SUCatalogType = .release

    let deferredSUEnablementDate: Date?

}

// MARK: - Resolving the macOS full product

extension SUMacOSPackage {

    static func resolve(from product: SUProduct) async throws -> SUMacOSPackage {

        // Use the URL in the distributions to get the version and build number
        guard let distributionURLString = product.distributions["English"] else {
            os_log(
                "When attempting to process the products, no English distribution was found. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.noenglishdistribution")
        }

        guard let distributionURL = URL(string: distributionURLString) else {
            os_log(
                "Somehow, the english distribution URL was invalid. Thanks Apple. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Distribution URL: \(distributionURLString)"
                + "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.invalidenglishdistributionurl")
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
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.nonhttpresponse")
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
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.standardhttp", data: "\(httpResponse.statusCode)")
        }

        guard let utf8String = String(data: data, encoding: .utf8) else {
            os_log(
                "When attempting to process the products, the distribution data could not be converted to a UTF8 string. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.utf8conversion")
        }

        guard let regex = try? Regex("<key>BUILD<\\/key>\\s*<string>([^<]+)<\\/string>\\s*<key>VERSION<\\/key>\\s*<string>([^<]+)<\\/string>") else {
            os_log(
                "When attempting to process the products, the regex could not be created. This is a bug. Please report. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.regexcreation")
        }

        let matches = utf8String.matches(of: regex)

        if matches.count == 0 {
            os_log(
                "When attempting to process the products, the regex did not match anything. Contexts:\n%@",
                log: LogCategory.swcanReader.osLog, type: .error,
                "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.regexnomatch")
        }

        guard let buildRaw = matches[0][1].substring, let versionRaw = matches[0][2].substring else {
            os_log("When attempting to process the products, the regex somehow failed, and no build or version number was extracted. Contexts:%@",
                   log: LogCategory.swcanReader.osLog, type: .error,
                   "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.regexnoextraction")
        }

        let buildNumber = buildRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        let version = versionRaw.trimmingCharacters(in: .whitespacesAndNewlines)

        // It's InstallAssistant.pkg, so it's a macOS 11+ installer, string to int stuff but split by the dot
        guard let majorVersionString = version.split(separator: ".").first else {
            os_log("When attempting to process the products, the version number could not be split into major and minor. Contexts:%@",
                   log: LogCategory.swcanReader.osLog, type: .error,
                   "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.versionnosplit")
        }

        guard var majorVersion = Int(majorVersionString) else {
            os_log("When attempting to process the products, the major version could not be converted to an integer. Contexts:%@",
                   log: LogCategory.swcanReader.osLog, type: .error,
                   "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.versionnointconversion")
        }

        if majorVersion < 10 {
            os_log("When attempting to process the products, the major version was less than 10. Contexts:%@",
                   log: LogCategory.swcanReader.osLog, type: .error,
                   "Product: \(product.key)\n"
            )
            throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.versionlessthan10")
        } else if majorVersion == 10 {
            // It's a macOS 10 installer, so the major version is 10XX
            guard let minorVersionString = version.split(separator: ".").dropFirst().first else {
                os_log("When attempting to process the products, the minor version could not be extracted. Contexts:%@",
                       log: LogCategory.swcanReader.osLog, type: .error,
                       "Product: \(product.key)\n"
                )
                throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.versionminor")
            }

            guard let minorVersion = Int(minorVersionString) else {
                os_log("When attempting to process the products, the minor version could not be converted to an integer. Contexts:%@",
                       log: LogCategory.swcanReader.osLog, type: .error,
                       "Product: \(product.key)\n"
                )
                throw SWError(source: "SUMacOSPackage.resolve()", id: "swerror.reader.versionminorintconversion")
            }

            majorVersion = 1000 + minorVersion
        }

        return SUMacOSPackage(key: product.key,
            serverMetadataURL: product.serverMetadataURL,
            packages: product.packages,
            postDate: product.postDate,
            distributions: product.distributions,
            extendedMetaInfo: product.extendedMetaInfo,
            version: version,
            buildNumber: buildNumber,
            majorVersion: majorVersion,
            insideCatalogs: product.insideCatalogs,
            deferredSUEnablementDate: product.deferredSUEnablementDate
        )
    }

}

// MARK: - Lovely Names

extension SUMacOSPackage {

    static func osName(for majorVersion: Int) -> String {
        switch majorVersion {
        case 1013:
            return "High Sierra"
        case 1014:
            return "Mojave"
        case 1015:
            return "Catalina"
        case 11:
            return "Big Sur"
        case 12:
            return "Monterey"
        case 13:
            return "Ventura"
        case 14:
            return "Sonoma"
        case 15:
            return "Sequoia"
        default:
            return "Unknown"
        }
    }

    var osName: String {
        return SUMacOSPackage.osName(for: majorVersion)
    }

}

// MARK: - SwiftUI Compatibility Stuff lols 10/10

extension SUMacOSPackage: Identifiable {
    
    var id: String { key }
    
    var image: Image {
        return Image(imageName)
    }
    
    var imageName: String {
        return self.osName.replacingOccurrences(of: " ", with: "") + "Circle"
    }

    // Post Date string for sorting, should just be an int as a string time since epoch
    var postDateForSorting: String {
        return "\(Int(postDate.timeIntervalSince1970))"
    }
    
}
