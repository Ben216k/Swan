//
//  SWError.swift - Swan
//
//  Created by Ben216k on 7/3/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import SwiftUI

struct SWError: Error {
    let source: String
    let id: String
    let localizedString: LocalizedStringResource
    let customText: String?
    let data: String?
    
    init(source: String, id: LocalizedStringResource, customText: String? = nil, data: String? = nil) {
        self.source = source
        self.id = id.key
        self.localizedString = id.localizedStringResource
        self.customText = customText
        self.data = data
    }
}

extension SWError {
    
    var localizedDescription: String {
        // check if localized string exists
        let localizedString = NSLocalizedString(id, comment: "")
        if localizedString != id {
            return (customText ?? localizedString.replacingOccurrences(of: "<DATA>", with: self.data ?? "<UNKNOWN DATA>")) + " (Code: \(id), Source: \(source))"
        }
        
        return (customText ?? NSLocalizedString("swerror.source.unknown", comment: "")) + " (Code: \(id), Source: \(source))"
    }
    
}


//extension LocalizedStringKey: @retroactive @unchecked Sendable {}
