// 
//  Initialization.swift - Swan
//
//  Created by Ben216k on 8/9/24
//  Copyright (c) Ben216k (under 216k License)
// 

import Foundation

extension SUCache {
    
    func beginFillingCache() async {
        self.catalogs = [:]
        self.products = [:]
        do {
            try await self.downloadUsedCatalogs()
        } catch {
            self.lifeSucks = error
            return
        }
        self.hasSetCaches = true
    }
    
}
