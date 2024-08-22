// 
//  SwanApp.swift - Swan
// 
//  Created by Ben216k on 8/3/24
//  Copyright (c) Ben216k (under 216k License)
// 


import SwiftUI
import SwiftData

@main
struct SwanApp: App {
    @StateObject var cache = SUCache.shared
    @StateObject var downloadManager = DownloadManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cache)
                .environmentObject(downloadManager)
                .frame(minWidth: 500, idealWidth: 800, maxWidth: .infinity, minHeight: 500, idealHeight: 700, maxHeight: .infinity)
                .presentedWindowToolbarStyle(.unified)
        }.windowResizability(WindowResizability.contentSize)
            .windowToolbarStyle(.unified)
            .commands {
                SidebarCommands()
                CommandGroup(after: .sidebar) {
                    Divider()
                    Button(cache.showTableFooter ? "swui.hidestatusbar" : "swui.showstatusbar") {
                        cache.showTableFooter.toggle()
                    }.keyboardShortcut("/", modifiers: .command)
                    Divider()
                }
            }
    }
}

extension SwanApp {
    
    static var pasteboard = NSPasteboard.general
    
    static func copyString(_ string: String) {
        SwanApp.pasteboard.declareTypes([.string], owner: nil)
        SwanApp.pasteboard.setString(string, forType: .string)
    }
    
    static let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    static let build = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!
    
}
