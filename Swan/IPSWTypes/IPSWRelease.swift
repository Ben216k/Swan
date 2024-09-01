// 
//  IPSWRelease.swift - Swan
// 
//  Created by Ben216k on 8/31/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import SwiftUI

// MARK: - Resolved IPSW Release

struct IPSWRelease: Identifiable, Sendable {
    let id: String // Same as IPSWReleasesRaw.id
    let name: String
    let dateString: String 
    let date: Date
    let count: Int
    let type: IPSWReleaseType 
    let version: String
    let buildNumber: String
    let majorVersion: Int

    var image: Image {
        Image(imageName)
    }

    var imageName: String {
        switch type {
        case .iOS:
            return "iOS\(majorVersion)Circle"
        case .iPadOS:
            // SUBJECT TO CHANGE
            return "iOS\(majorVersion)Circle"
        case .audioOS:
            return "audioOSCircle"
        case .tvOS:
            return "tvOSCircle"
        case .watchOS:
            return "watchOSCircle"
        }
    }

    static func resolved(from raw: IPSWReleasesRaw) -> IPSWRelease? {
        guard !raw.type.contains("OTA") && IPSWReleaseType.allCases.contains(where: { $0.rawValue == raw.type }) else {
            return nil
        }
        
        // Separate version and build number from the name
        let nameComponents = raw.name.components(separatedBy: " ")
        guard let version = nameComponents.first(where: { $0.contains(".") }), // Find the component with "."
              let buildNumber = nameComponents.first(where: { $0.starts(with: "(") && $0.hasSuffix(")") })?.dropFirst().dropLast()
        else { 
            return nil 
        }

        // Get major version for image naming
        let versionParts = version.components(separatedBy: ".") 
        guard let majorVersion = Int(versionParts[0]) else { return nil }

        // Convert date string to Date
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: raw.date) else { return nil }

        return IPSWRelease(
            id: raw.id,
            name: raw.name,
            dateString: raw.date,
            date: date,
            count: raw.count,
            type: IPSWReleaseType(rawValue: raw.type)!,
            version: version,
            buildNumber: String(buildNumber),
            majorVersion: majorVersion
        )
    }
}

enum IPSWReleaseType: String, CaseIterable, Codable {
    case iOS = "iOS"
    case iPadOS = "iPadOS"
    case watchOS = "watchOS"
    case tvOS = "tvOS"
    case audioOS = "audioOS"
    
    var localizedKey: LocalizedStringKey {
        switch self {
        case .iOS: return "swui.ipswtype.ios"
        case .iPadOS: return "swui.ipswtype.ipados"
        case .watchOS: return "swui.ipswtype.watchos"
        case .tvOS: return "swui.ipswtype.tvos"
        case .audioOS: return "swui.ipswtype.audioos"
        }
    }
}

extension IPSWRelease {
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    var postDateForSorting: String {
        return "\(Int(date.timeIntervalSince1970))"
    }
}
