// 
//  CollapsibleHeader.swift - Swan
// 
//  Created by Ben216k on 8/20/24
//  Copyright (c) Ben216k (under 216k License)
//

import SwiftUI

struct CollapsibleHeader: View {
    
    let title: LocalizedStringResource
    @Binding var isCollapsed: Bool
    
    var body: some View {
        
        HStack {
            Text(title)
            Spacer()
            Button { isCollapsed.toggle() } label: {
                Image(systemName: !isCollapsed ? "chevron.forward" : "chevron.down")
            }.buttonStyle(.borderless)
        }
        
        
    }
    
    init(key title: LocalizedStringResource, isCollapsed: Binding<Bool>) {
        self.title = title
        self._isCollapsed = isCollapsed
    }
    
    init(_ title: String, isCollapsed: Binding<Bool>) {
        self.title = .init(stringLiteral: title)
        self._isCollapsed = isCollapsed
    }
    
}
