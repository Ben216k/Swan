// 
//  FakeTableItem.swift - Swan
// 
//  Created by Ben216k on 8/9/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct FakeTableItem: View {
    var title: LocalizedStringKey
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .textSelection(.enabled)
        }
//        .padding(.bottom, -5)
        .font(.subheadline)
//        Divider()
        
        // This code used to function without lists, now it depends on them. Lols
    }
}
