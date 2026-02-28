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
    @Environment(\.openWindow) private var openWindow
    
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
                    Button(cache.showUnformattedName ? "swui.hideunformattedname" : "swui.showunformattedname") {
                        cache.showUnformattedName.toggle()
                    }.keyboardShortcut(".", modifiers: [.command, .shift])
                    Divider()
                }
                CommandGroup(after: .newItem) {
                    Divider()
                    Button("swui.showcacheinfinder") {
                        NSWorkspace.shared.activateFileViewerSelecting([cache.cacheDirectoryURL])
                    }
                    Button("swui.clearlocalcache") {
                        let alert = NSAlert()
                            
                        // Set the alert message and informative text
                        alert.messageText = NSLocalizedString("swui.clearlocalcache", comment: "")
                        alert.informativeText = NSLocalizedString("swui.clearlocalcache.description", comment: "")
                        
                        // Add buttons
                        alert.addButton(withTitle: NSLocalizedString("swui.confirm", comment: ""))
                        alert.addButton(withTitle: NSLocalizedString("swui.cancel", comment: ""))
                        
                        // Set the alert style (optional)
                        alert.alertStyle = .warning
                        
                        // Show the alert as a modal dialog and handle the user's response
                        let response = alert.runModal()
                        
                        // Check the response
                        if response == .alertFirstButtonReturn {
                            cache.clearCache()
                            cache.clearCatalogs()
                            Task {
                                await cache.beginFillingCache()
                            }
                        } else {
                            
                        }
                    }.keyboardShortcut("k", modifiers: [.shift, .command])
                    Button("swui.clearunknowncache") {
                        let alert = NSAlert()
                            
                        // Set the alert message and informative text
                        alert.messageText = NSLocalizedString("swui.clearunknowncache", comment: "")
                        alert.informativeText = NSLocalizedString("swui.clearunknowncache.description", comment: "")
                        
                        // Add buttons
                        alert.addButton(withTitle: NSLocalizedString("swui.confirm", comment: ""))
                        alert.addButton(withTitle: NSLocalizedString("swui.cancel", comment: ""))
                        
                        // Set the alert style (optional)
                        alert.alertStyle = .warning
                        
                        // Show the alert as a modal dialog and handle the user's response
                        let response = alert.runModal()
                        
                        // Check the response
                        if response == .alertFirstButtonReturn {
                            cache.clearUnknownCache()
                        } else {
                            
                        }
                    }.keyboardShortcut("k", modifiers: [.shift, .command, .option])
                    Divider()
                }
                
                CommandGroup(replacing: .appInfo) {
                    Button("About Swan") { openWindow(id: "about-swan") }
                }
                
            }
        
        Window("About Swan", id: "about-swan") {
            AboutSwanView()
        }.windowResizability(WindowResizability.contentSize)
        
        Settings {
            PreferencesView()
                .environmentObject(cache)
        }.windowResizability(WindowResizability.contentSize)
    }
}

extension SwanApp {
    
    static var pasteboard = NSPasteboard.general
    
    static func copyString(_ string: String) {
        SwanApp.pasteboard.declareTypes([.string], owner: nil)
        SwanApp.pasteboard.setString(string, forType: .string)
    }
    
    static let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    static let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    
}
