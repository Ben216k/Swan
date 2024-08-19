// 
//  HTMLRenderer.swift - Swan
// 
//  Created by Ben216k on 8/19/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI
import WebKit

struct HTMLRenderer: NSViewRepresentable {
    let htmlString: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // No updates needed for static HTML content 
    }
}
