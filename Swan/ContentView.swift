// 
//  ContentView.swift - Swan
// 
//  Created by Ben216k on 8/3/24
//  Copyright (c) Ben216k (under 216k License)
// 


import SwiftUI
import SwiftData

@MainActor
struct ContentView: View {

    @EnvironmentObject var cache: SUCache
    @EnvironmentObject var downloadManager: DownloadManager
    
    @State var columnVisibility = NavigationSplitViewVisibility.all
    @State var selectedProduct: String?
    @State var listSelection: String? = "macOS"
    @State var showDownloadManager = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                List(selection: $listSelection) {
                    Section("swui.producttypes") {
                        NavigationLink(value: "macOS", label: { Text("swui.macospackages") } )
                        NavigationLink(value: "Safari", label: { Text("swui.safaripackages") } )
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
            switch listSelection {
            case "macOS": MacOSListView(selection: $selectedProduct)
            case "Safari": SafariListView(selection: $selectedProduct)
            default: Rectangle().frame(height: 1).opacity(0.000001)
            }
        } detail: {
            Group {
                if let lifeSucks = cache.lifeSucks {
                    SWErrorTotalView(error: lifeSucks)
                } else if !cache.hasSetCaches {
                    Text("swui.loadingcatalogs")
                } else {
                    switch cache.products[selectedProduct ?? "unused"]?.type {
                    case .macOSpackage:
                        MacOSItemDetailView(selection: $selectedProduct)
                    case .safari:
                        SafariItemDetailView(selection: $selectedProduct)
                    case .none:
                        Text("swui.noitemselected")
                    }
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
        }
    }

}

#Preview {
    ContentView()
}
