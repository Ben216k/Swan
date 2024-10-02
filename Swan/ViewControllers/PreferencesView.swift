// 
//  PreferencesView.swift - Swan
// 
//  Created by Ben216k on 9/1/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var cache: SUCache
    
    var body: some View {
        TabView {
            SidebarSettings()
                .tabItem {
                    Label("Sidebar", systemImage: "sidebar.left")
                }
            TableSettings()
                .tabItem {
                    Label("Table", systemImage: "tablecells.badge.ellipsis")
                }
        }.frame(width: 500, height: 600)
            .navigationTitle(Text("Swan Preferences"))
    }
}

#Preview {
    PreferencesView()
        .environmentObject(SUCache())
}

struct TableSettings: View {
    @EnvironmentObject var cache: SUCache
    
    var body: some View {
        Form {
//            Toggle(isOn: .constant(true), label: "Show Formatted Names")
            Toggle("Show Unformatted Names", isOn: $cache.showUnformattedName)
            Toggle("Show Status Bar", isOn: $cache.showTableFooter)
        }.formStyle(.grouped)
    }
}

struct SidebarSettings: View {
    @EnvironmentObject var cache: SUCache
    
    var body: some View {
        Form {
            Section(header: Text("Shown Items")) {
                Toggle(isOn: cache.bindingForSidebarOption(id: "All")) { Label("swui.allproducts", systemImage: "circle.grid.3x3.fill") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "macOS")) { Label("swui.macospackages", systemImage: "shippingbox") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "bridgeOS")) { Label("swui.bridgeosupdates", systemImage: "cpu") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "BootCamp")) { Label("swui.bootcamp", systemImage: "window.vertical.closed") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "CLTools")) { Label("swui.cltools", systemImage: "apple.terminal") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "Safari")) { Label("swui.safaripackages", systemImage: "safari") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "Voices")) { Label("swui.voiceupdate", systemImage: "person.wave.2") }
                
                Toggle(isOn: cache.bindingForSidebarOption(id: "Beats")) { Label("swui.beats", systemImage: "beats.powerbeatspro.chargingcase") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "DeviceSupport")) { Label("swui.devicesupport", systemImage: "iphone.circle") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "iTunes")) { Label("iTunes", systemImage: "music.quarternote.3") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "ProVideo")) { Label("swui.provideoformats", systemImage: "video") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "LogicPro")) { Label("Logic Pro", systemImage: "record.circle.fill") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "SFSymbols")) { Label("swui.sfsymbols", systemImage: "star") }
                Toggle(isOn: cache.bindingForSidebarOption(id: "Unknown")) { Label("swui.unknown", systemImage: "questionmark.app.dashed") }
            }
        }.formStyle(.grouped)
    }
}
