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
                        if cache.isSidebarOptionEnabled(id: "All")
                            { NavigationLink(value: "All", label: { Label("swui.allproducts", systemImage: "circle.grid.3x3.fill") } ) }
                        if cache.isSidebarOptionEnabled(id: "macOS")
                            { NavigationLink(value: "macOS", label: { Label("swui.macospackages", systemImage: "shippingbox") } ) }
                        if cache.isSidebarOptionEnabled(id: "bridgeOS")
                            { NavigationLink(value: "bridgeOS", label: { Label("swui.bridgeosupdates", systemImage: "cpu") } ) }
                        if cache.isSidebarOptionEnabled(id: "BootCamp")
                            { NavigationLink(value: "BootCamp", label: { Label("swui.bootcamp", systemImage: "window.vertical.closed") } ) }
                        if cache.isSidebarOptionEnabled(id: "CLTools")
                            { NavigationLink(value: "CLTools", label: { Label("swui.cltools", systemImage: "apple.terminal") } ) }
                        if cache.isSidebarOptionEnabled(id: "Safari")
                            { NavigationLink(value: "Safari", label: { Label("swui.safaripackages", systemImage: "safari") } ) }
                        if cache.isSidebarOptionEnabled(id: "Voices")
                            { NavigationLink(value: "Voices", label: { Label("swui.voiceupdate", systemImage: "person.wave.2") } ) }
                        
                        if cache.isSidebarOptionEnabled(id: "Beats")
                            { NavigationLink(value: "Beats", label: { Label("swui.beats", systemImage: "beats.powerbeatspro.chargingcase") } ) }
                        if cache.isSidebarOptionEnabled(id: "DeviceSupport")
                            { NavigationLink(value: "DeviceSupport", label: { Label("swui.devicesupport", systemImage: "iphone.circle") } ) }
                        if cache.isSidebarOptionEnabled(id: "iTunes")
                            { NavigationLink(value: "iTunes", label: { Label("iTunes", systemImage: "music.quarternote.3") } ) }
                        if cache.isSidebarOptionEnabled(id: "iTunes")
                            { NavigationLink(value: "ProVideo", label: { Label("swui.provideoformats", systemImage: "video") } ) }
                        if cache.isSidebarOptionEnabled(id: "LogicPro")
                            { NavigationLink(value: "LogicPro", label: { Label("Logic Pro", systemImage: "record.circle.fill") } ) }
                        if cache.isSidebarOptionEnabled(id: "SFSymbols")
                            { NavigationLink(value: "SFSymbols", label: { Label("swui.sfsymbols", systemImage: "star") } ) }
                        if cache.isSidebarOptionEnabled(id: "Unknown")
                            { NavigationLink(value: "Unknown", label: { Label("swui.unknown", systemImage: "questionmark.app.dashed") } ) }
                        
                    }
                    // Will be back <3
//                    Section("swui.ipswtypes") {
//                        NavigationLink(value: "AllIPSW", label: { Text("swui.allipsws") } )
//                        NavigationLink(value: "iOSIPSW", label: { Text("swui.ios") } )
//                        NavigationLink(value: "iPadOSIPSW", label: { Text("swui.ipados") } )
////                        NavigationLink(value: "TVIPSW", label: { Text("swui.tvOS") } )
//                        NavigationLink(value: "AUDIOIPSW", label: { Text("swui.audioOS") } )
//                        NavigationLink(value: "WATCHIPSW", label: { Text("swui.watchOS") } )
//                    }
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
                    case "macOS": EVERYTHINGListView(selection: $selectedProduct, filterType: .macOSpackage)
                    case "CLTools": EVERYTHINGListView(selection: $selectedProduct, filterType: .cltools)
                    case "bridgeOS": EVERYTHINGListView(selection: $selectedProduct, filterType: .bridgeOS)
                    case "BootCamp": EVERYTHINGListView(selection: $selectedProduct, filterType: .bootcamp)
                    case "Safari": EVERYTHINGListView(selection: $selectedProduct, filterType: .safari)
                    case "SecUpd": EVERYTHINGListView(selection: $selectedProduct, filterType: .securityupdate)
                    case "Voices": EVERYTHINGListView(selection: $selectedProduct, filterType: .voiceupdate)
                        
                    case "Beats": EVERYTHINGListView(selection: $selectedProduct, filterType: SUProductType.beats)
                    case "DeviceSupport": EVERYTHINGListView(selection: $selectedProduct, filterType: SUProductType.devicesupport)
                    case "iTunes": EVERYTHINGListView(selection: $selectedProduct, filterType: SUProductType.itunes)
                    case "LogicPro": EVERYTHINGListView(selection: $selectedProduct, filterType: SUProductType.logicpro)
                    case "ProVideo": EVERYTHINGListView(selection: $selectedProduct, filterType: SUProductType.provideoformat)
                    case "SFSymbols": EVERYTHINGListView(selection: $selectedProduct, filterType: SUProductType.sfsymbols)
                    case "Unknown": EVERYTHINGListView(selection: $selectedProduct, filterType: SUProductType.unknown)
                        
                    case "AllIPSW": IPSWListView(selection: $selectedProduct, filterType: nil)
                    case "iOSIPSW": IPSWListView(selection: $selectedProduct, filterType: .iOS)
                    case "iPadOSIPSW": IPSWListView(selection: $selectedProduct, filterType: .iPadOS)
                    case "AUDIOIPSW": IPSWListView(selection: $selectedProduct, filterType: .audioOS)
                    case "WATCHIPSW": IPSWListView(selection: $selectedProduct, filterType: .watchOS)
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
