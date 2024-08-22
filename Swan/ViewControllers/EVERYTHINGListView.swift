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
    let filterType: SUProductType?
    
    var body: some View {
        VStack(spacing: 0) {
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
                ForEach(cache.everythingProduts.filter { $0.type == filterType ?? $0.type }) { item in
                    TableRow(item)
                }
            }.searchable(text: $cache.search, prompt: "swui.search").navigationSubtitle(filterType?.localizedKey ?? "swui.allproducts")
            if cache.showTableFooter {
                Divider()
                ZStack {
                    Rectangle().foregroundStyle(Color(NSColor.controlBackgroundColor))
                    Text("\(cache.everythingProduts.filter { $0.type == filterType ?? $0.type }.count) items.")
                        .padding(5).padding(.horizontal, 2.5).padding(.bottom, 1)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }.fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
}
