// 
//  SafariListView.swift - Swan
//
//  Created by Ben216k on 8/12/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI
import os

@MainActor
struct SafariListView: View {
    
    @EnvironmentObject var cache: SUCache
    
    @Binding var selection: String?
    @State private var searchText: String = ""
    @State private var showSearchBar = false
    
    var body: some View {
        Table(of: SUSafariResolved.self, selection: $selection, sortOrder: $cache.safariSortOrder) {
            TableColumn("") { item in
                item.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .cornerRadius(100)
            }.width(35)
            TableColumn("swui.name", value: \.basicName)
            TableColumn("swui.version", value: \.version)
                .width(min: 90, ideal: 90, max: 120)
            TableColumn("swui.macosversion", value: \.macOSVersion)
            TableColumn("swui.catalog") { item in
                Text(item.releaseType.name)
            }.width(min: 90, ideal: 90, max: 120)
            TableColumn("swui.productid", value: \.key)
                .width(min: 80, ideal: 80, max: 90)
            TableColumn("swui.postdate", value: \.postDateForSorting) {
                Text($0.postDateFormatted)
            }
        } rows: {
            ForEach(cache.safariPackages) { item in
                TableRow(item)
            }
        }.searchable(text: $cache.search, prompt: "swui.search").navigationSubtitle("swui.safaripackages")
    }
    
}
