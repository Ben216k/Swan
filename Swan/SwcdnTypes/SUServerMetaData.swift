// 
//  SUServerMetaData.swift - Swan
// 
//  Created by Ben216k on 8/19/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation

struct SUServerMetadata: Codable, Sendable {
    let version: String
    let localizations: [String: SUSMDLocalization]
    let platforms: SUSMDPlatforms
    
    enum CodingKeys: String, CodingKey {
        case version = "CFBundleShortVersionString"
        case localizations = "localization"
        case platforms = "platforms"
    }
}

struct SUSMDLocalization: Codable, Sendable {
    let descriptionData: Data
    let serverComment: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case descriptionData = "description"
        case serverComment = "serverComment"
        case title = "title"
    }

    var descriptionHTML: String? {
        return String(data: descriptionData, encoding: .utf8)
    }
}

struct SUSMDPlatforms: Codable, Sendable {
    let client: [String]?
    let server: [String]?
    
    enum CodingKeys: String, CodingKey {
        case client = "client"
        case server = "server"
    }
} 
