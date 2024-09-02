// 
//  HTMLRenderer.swift - Swan
// 
//  Created by Ben216k on 8/19/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI
import WebKit

#if os(macOS)
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
#elseif os(iOS)
struct HTMLRenderer: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed for static HTML content
    }
}
#endif
