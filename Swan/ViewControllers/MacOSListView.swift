// 
//  MainList.swift - Swan
// 
//  Created by Ben216k on 8/7/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI
import os

@MainActor
struct MacOSListView: View {
    
    @EnvironmentObject var cache: SUCache
    
    @Binding var selection: String?
    @State private var searchText: String = ""
    @State private var showSearchBar = false
    
    var body: some View {
        Table(of: SUMacOSPackage.self, selection: $selection, sortOrder: $cache.macOSpackagesSortOrder) {
            TableColumn("") { item in
                item.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .cornerRadius(100)
            }.width(35)
            TableColumn("swui.majorversion", value: \.osName) { item in
                Text("macOS " + item.osName)
            }
            TableColumn("swui.minorversion", value: \.version)
                .width(min: 60, ideal: 60, max: 70)
            TableColumn("swui.buildnumber", value: \.buildNumber)
            TableColumn("swui.catalog") { item in
                Text(item.releaseType.name)
            }
            TableColumn("swui.productid", value: \.key)
                .width(min: 80, ideal: 80, max: 90)
            TableColumn("swui.postdate", value: \.postDateForSorting) {
                Text($0.postDateFormatted)
            }
        } rows: {
            ForEach(cache.macOSpackages) { item in
                TableRow(item)
                    .contextMenu {
                        if let iaLink = item.packages.first(where: { $0.url.contains("InstallAssistant.pkg") })?.url {
                            Button {
                                SwanApp.copyString(iaLink)
                            } label: {
                                Text("swui.copy.installassistantlink")
                            }
                        }
                        Button {
                            SwanApp.copyString("\(item)")
                        } label: {
                            Text("swui.copy.dump")
                        }
                        if let htmlDescription = item.serverMetadata?.localizations["English"]?.descriptionHTML {
                            Button {
                                SwanApp.copyString(htmlDescription)
                            } label: {
                                Text("swui.copy.htmlservermetadata")
                            }
                        }
                    }
            }
        }.searchable(text: $cache.search, prompt: "swui.search").navigationSubtitle("swui.macospackages")
    }
    
}
