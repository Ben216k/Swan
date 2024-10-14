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
            if filterType == .macOSpackage { MacOSListView(selection: $selection) }
            else if filterType == .safari { SafariListView(selection: $selection) }
            else {
                Table(of: SUFakedResolved.self, selection: $selection, sortOrder: $cache.everythingSortOrder) {
                    TableColumn("") { item in
                        item.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .cornerRadius(100)
                    }.width(35)
                    TableColumn(cache.showUnformattedName ? "swui.unformattedname" : "swui.name", value: \.basicName) { item in
                        if cache.showUnformattedName {
                            Text(item.unformattedName).foregroundStyle(item.deprecated ? .secondary : .primary)
                        } else {
                            Text(item.basicName).foregroundStyle(item.deprecated ? .secondary : .primary)
                        }
                    }
                    TableColumn("swui.version", value: \.version) { item in
                        Text(item.version)
                            .foregroundStyle(item.deprecated ? .secondary : .primary)
                    }
                    .width(min: 90, ideal: 100, max: 140)
                    
                    //                          If is Available macOS 14.4 and later.
                    //                if filterType == .macOSpackage {
                    //                    TableColumn("swui.buildnumber", value: \.buildNumber) { item in
                    //                        Text(item.buildNumber)
                    //                            .foregroundStyle(item.deprecated ? .secondary : .primary)
                    //                    }
                    //                }
                    //                          If is Available macOS 14.4 and later.
                    
                    TableColumn("swui.catalog") { item in
                        Text(item.releaseType.name)
                            .foregroundStyle(item.deprecated ? .secondary : .primary)
                    }.width(min: 90, ideal: 90, max: 100)
                    TableColumn("swui.productid", value: \.key) { item in
                        Text(item.key)
                            .foregroundStyle(item.deprecated ? .secondary : .primary)
                    }
                    .width(min: 80, ideal: 80, max: 90)
                    TableColumn("swui.postdate", value: \.postDateForSorting) { item in
                        Text(item.postDateFormatted)
                            .foregroundStyle(item.deprecated ? .secondary : .primary)
                    }.width(min: 90, ideal: 90, max: 100)
                    TableColumn("swui.status", value: \.deprecatedString) { item in
                        Text(item.deprecated ? "swui.deprecated" : "swui.present")
                            .foregroundStyle(item.deprecated ? .secondary : .primary)
                    }.width(min: 80, ideal: 80, max: 80)
                } rows: {
                    ForEach(cache.everythingProduts.filter { $0.type == filterType ?? $0.type }) { item in
                        TableRow(item)
                    }
                }
            }
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
            
        }.searchable(text: $cache.search, prompt: "swui.search").navigationSubtitle(filterType?.localizedKey ?? "swui.allproducts")
    }
    
}
