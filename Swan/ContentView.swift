// 
//  ContentView.swift - Swan
// 
//  Created by Ben216k on 8/3/24
//  Copyright (c) Ben216k (under 216k License)
// 


import SwiftUI
import SwiftData
import os

@MainActor
struct ContentView: View {

    @EnvironmentObject var cache: SUCache
    @EnvironmentObject var downloadManager: DownloadManager
    
    @State var columnVisibility = NavigationSplitViewVisibility.all
    @State var selectedProduct: String?
    @State var listSelection: String? = "All"
    @State var showDownloadManager = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                List(selection: $listSelection) {
                    Section("swui.producttypes") {
                        NavigationLink(value: "All", label: { Text("swui.allproducts") } )
                        NavigationLink(value: "CLTools", label: { Text("swui.cltools") } )
                        NavigationLink(value: "bridgeOS", label: { Text("swui.bridgeosupdates") } )
                        NavigationLink(value: "macOS", label: { Text("swui.macospackages") } )
                        NavigationLink(value: "Safari", label: { Text("swui.safaripackages") } )
                        NavigationLink(value: "SecUpd", label: { Text("swui.securityupdates") } )
                    }
                }.listStyle(.sidebar)
                Spacer()
                HStack {
                    Text("216k Labs")
                        .foregroundStyle(.secondary)
                        .padding([.bottom, .horizontal], 12)
                    Spacer()
                }
            }
        } content: {
//            MacOSListView(selection: $selectedProduct)
            Group {
                if cache.hasSetCaches {
                    switch listSelection {
                    case "All": EVERYTHINGListView(selection: $selectedProduct, filterType: nil)
                    case "CLTools": EVERYTHINGListView(selection: $selectedProduct, filterType: .cltools)
                    case "bridgeOS": EVERYTHINGListView(selection: $selectedProduct, filterType: .bridgeOS)
                    case "macOS": MacOSListView(selection: $selectedProduct)
                    case "Safari": SafariListView(selection: $selectedProduct)
                    case "SecUpd": EVERYTHINGListView(selection: $selectedProduct, filterType: .securityupdate)
                    default: Rectangle().frame(height: 1).opacity(0.000001)
                    }
                } else {
                    Rectangle().opacity(0.0000001)
                }
            }
        } detail: {
            Group {
                if let lifeSucks = cache.lifeSucks {
                    SWErrorTotalView(error: lifeSucks)
                } else if !cache.hasSetCaches {
                    Text("swui.loadingcatalogs")
                } else {
//                    switch cache.products[selectedProduct ?? "unused"]?.type {
//                    case .macOSpackage:
//                        MacOSItemDetailView(selection: $selectedProduct)
//                    case .safari:
//                        SafariItemDetailView(selection: $selectedProduct)
//                    case .none:
//                        Text("swui.noitemselected")
//                    }
                    ProductDetailView(selection: $selectedProduct)
                }
            }.navigationSplitViewColumnWidth(min: 250, ideal: 315, max: 350)
        }.toolbar {
            ToolbarItem(id: "downloads") {
                Button {
                    showDownloadManager.toggle()
                } label: {
                    VStack {
                        Label("swui.showdownloads", systemImage: downloadManager.bestSFSymbol)
                        if downloadManager.isWithinHumanableRange {
                            ZStack(alignment: .leading) {
                                Rectangle().frame(width: CGFloat(min(downloadManager.downloadTasks.progress * 25, 25)), height: 5).foregroundColor(.accentColor)
                                Rectangle().frame(width: 25, height: 5).foregroundColor(.secondary)
                            }.cornerRadius(10)
                        }
                    }
                        .help("swui.showdownloads")
                }.popover(isPresented: $showDownloadManager) {
                    DownloadManagerView().frame(width: 350)
                }
            }
            ToolbarItem {
                Button {
                    if cache.hasSetCaches {
                        os_log("User requested catalog to be loaded.", log: LogCategory.mainUI.osLog, type: .default)
                        cache.clearCatalogs()
                        Task {
                            await cache.beginFillingCache()
                        }
                    }
                } label: {
                    Label("swui.refreshlist", systemImage: "arrow.clockwise")
                        .help("swui.refreshlist")
                }.disabled(!cache.hasSetCaches)
            }
        }
    }

}
