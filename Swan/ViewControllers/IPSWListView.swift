// 
//  IPSWListView.swift - Swan
// 
//  Created by Ben216k on 8/31/24
//  Copyright (c) Ben216k (under 216k License)
//

import SwiftUI
import os

@MainActor
struct IPSWListView: View {
    
    @EnvironmentObject var cache: SUCache
    
    @Binding var selection: String?
    @State private var searchText: String = ""
    @State private var showSearchBar = false
    @State var filterType: IPSWReleaseType?
    
    var body: some View {
        VStack(spacing: 0) {
            Table(of: IPSWRelease.self, selection: $selection, sortOrder: $cache.ipswSortOrder) {
                TableColumn("") { item in
                    item.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                        .cornerRadius(100)
                }.width(35)
                TableColumn("swui.name") {
                    Text($0.name.split(separator: " ")[0])
                }.width(min: 70, ideal: 80, max: 90)
                TableColumn("swui.version", value: \.version)
                    .width(min: 70, ideal: 80, max: 90)
                TableColumn("swui.buildnumber", value: \.buildNumber)
                TableColumn("swui.postdate", value: \.postDateForSorting) {
                    Text($0.formattedDate)
                }
            } rows: {
                ForEach(cache.ipsws.filter { $0.type == filterType ?? $0.type }) { item in
                    TableRow(item)
                }
            }
            if cache.showTableFooter {
                Divider()
                ZStack {
                    #if os(macOS)
                    Rectangle().foregroundStyle(Color(NSColor.controlBackgroundColor))
#endif
                    Text("\(cache.ipsws.filter { $0.type == filterType ?? $0.type }.count) items.")
                        .padding(5).padding(.horizontal, 2.5).padding(.bottom, 1)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }.fixedSize(horizontal: false, vertical: true)
            }
        }.searchable(text: $cache.search, prompt: "swui.search")
        #if os(macOS)
            .navigationSubtitle(filterType?.localizedKey ?? "swui.allipsws")
        #endif
    }
    
}
