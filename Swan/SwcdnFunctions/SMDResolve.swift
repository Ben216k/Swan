// 
//  SMDResolve.swift - Swan
// 
//  Created by Ben216k on 8/19/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import os

extension SUProduct {

    func resolveServerMetadata() async throws -> SUServerMetadata? {
        guard let serverMetadataURL = serverMetadataURL,
              let url = URL(string: serverMetadataURL) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else { return nil }

            let decoder = PropertyListDecoder()
            let serverMetadata = try decoder.decode(SUServerMetadata.self, from: data)
            return serverMetadata

        } catch {
            // Log the error (you can use your Logger class here)
            os_log(
                "Error resolving server metadata: %@ for URL: %@",
                log: LogCategory.swcanReader.osLog,
                type: .error,
                error.localizedDescription,
                url.absoluteString
            )

            return nil
        }
    }
}
