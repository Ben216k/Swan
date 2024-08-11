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

    @EnvironmentObject var downloadManager: DownloadManager
    
    @State var columnVisibility = NavigationSplitViewVisibility.all
    @State var selectedProduct: String?
    @State var listSelection: String? = "macOS"
    @State var showDownloadManager = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                List(selection: $listSelection) {
                    Section("Types") {
                        NavigationLink(value: "macOS", label: { Text("swui.macospackages") } )
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
            default: Rectangle().frame(height: 1).opacity(0.000001)
            }
        } detail: {
            MacOSItemDetailView(selection: $selectedProduct)
                .navigationSplitViewColumnWidth(min: 250, ideal: 315, max: 350)
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
