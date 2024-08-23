// 
//  MacOSTableView.swift - Swan
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
    
    var body: some View {
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
            
            TableColumn("swui.buildnumber", value: \.buildNumber) { item in
                Text(item.buildNumber)
                    .foregroundStyle(item.deprecated ? .secondary : .primary)
            }
            
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
            ForEach(cache.everythingProduts.filter { $0.type == .macOSpackage }) { item in
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
        }
    }
    
}
