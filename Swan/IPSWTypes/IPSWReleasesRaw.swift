// 
//  IPSWReleasesRaw.swift - Swan
// 
//  Created by Ben216k on 8/31/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation

// MARK: - Raw Data Structs

struct IPSWReleasesRawWrapper: Decodable, Sendable {
    let date: String
    let releases: [IPSWReleasesRaw]
}

struct IPSWReleasesRaw: Decodable, Sendable, Identifiable {
    let name: String
    let date: String
    let count: Int
    let type: String

    var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name, date, count, type
    }
}
