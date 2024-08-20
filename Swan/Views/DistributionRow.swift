// 
//  DistributionRow.swift - Swan
// 
//  Created by Ben216k on 8/19/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct DistributionRow: View {
    let name: String
    let url: URL
    let product: any SUProductResolved
    @EnvironmentObject var downloadManager: DownloadManager
    
    var body: some View {
        HStack {
            Text(name)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            Spacer()
            Text(url.absoluteString)
                .lineLimit(1)
                .truncationMode(.head)
                .frame(width: 125)
            Button {
                Task {
                    try? await downloadManager.startDownload(from: url, 
                                                         title: product.downloadTitleText,
                                                         specific: "\(product.downloadSubtitleText) | \(url.lastPathComponent)",
                                                         image: product.imageName)
                }
            } label: {
                Image(systemName: "arrow.down.circle")
            }.buttonStyle(.borderless)
            Button {
                SwanApp.copyString(url.absoluteString)
            } label: {
                Image(systemName: "doc.on.doc")
            }.buttonStyle(.borderless)
        }
        .font(.subheadline)
    }
}
