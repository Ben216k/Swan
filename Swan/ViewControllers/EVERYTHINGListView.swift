// 
//  EVERYTHINGListView.swift - Swan
// 
//  Created by Ben216k on 8/20/24
//  Copyright (c) Ben216k (under 216k License)
//

import SwiftUI
import os

@MainActor
struct EVERYTHINGListView: View {
    
    @EnvironmentObject var cache: SUCache
    
    @Binding var selection: String?
    @State private var searchText: String = ""
    @State private var showSearchBar = false
    
    var body: some View {
        Table(of: SUFakedResolved.self, selection: $selection, sortOrder: $cache.everythingSortOrder) {
            TableColumn("") { item in
                item.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .cornerRadius(100)
            }.width(35)
            TableColumn("swui.name", value: \.basicName)
            TableColumn("swui.version", value: \.version)
                .width(min: 90, ideal: 100, max: 140)
            TableColumn("swui.catalog") { item in
                Text(item.releaseType.name)
            }
            TableColumn("swui.productid", value: \.key)
                .width(min: 80, ideal: 80, max: 90)
            TableColumn("swui.postdate", value: \.postDateForSorting) {
                Text($0.postDateFormatted)
            }
        } rows: {
            ForEach(cache.everythingProduts) { item in
                TableRow(item)
            }
        }.searchable(text: $cache.everythingSearch, prompt: "swui.search").navigationSubtitle("swui.safaripackages")
    }
    
}
