// 
//  FetchIPSW.swift - Swan
// 
//  Created by Ben216k on 8/31/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation

extension SUCache {

    func fetchIPSWReleases() async throws(SWError) -> [IPSWRelease] {
        guard let url = URL(string: "https://api.ipsw.me/v4/releases") else {
            throw SWError(source: "SUCache.fetchIPSWReleases()", id: "swerror.ipsw.invalidurl")
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw SWError(source: "SUCache.fetchIPSWReleases()", id: "swerror.ipsw.httpError", data: "\((response as? HTTPURLResponse)?.statusCode ?? -1)")
            }

            let decoder = JSONDecoder()
            let rawReleases = try decoder.decode([IPSWReleasesRawWrapper].self, from: data)

            let resolvedReleases = rawReleases.flatMap { $0.releases }
                                          .compactMap { IPSWRelease.resolved(from: $0) }

            return resolvedReleases
        } catch {
            // If the error is already an SWError, rethrow it
            if let swError = error as? SWError {
                throw swError
            } else {
                // Otherwise, wrap the error in an SWError
                throw SWError(source: "SUCache.fetchIPSWReleases()", id: "swerror.foundation.unknown", customText: error.localizedDescription)
            }
        }
    }
}
