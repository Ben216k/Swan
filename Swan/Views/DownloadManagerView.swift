// 
//  DownloadManagerView.swift - Swan
// 
//  Created by Ben216k on 8/10/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

#if os(macOS)
struct DownloadManagerView: View {
    @EnvironmentObject var cache: SUCache
    @EnvironmentObject var downloadManager: DownloadManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("swui.downloads")
                        .padding(.bottom, 10)
                    Spacer()
                }
                
                if downloadManager.downloadTasks.isEmpty {
                    Text("swui.nocurrentdownloads")
                }
                ForEach(downloadManager.downloadTasks) { task in
                    
                    HStack {
                        Image(task.imageString)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .cornerRadius(100)
                            .padding(.trailing, 1)
                        VStack(alignment: .leading) {
                            Text(task.titleInfo)
                                .font(.headline.bold())
                            Text(task.specificInfo)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let destinationURL = task.destinationURL {
                            VStack {
                                Spacer()
                                Button {
                                    NSWorkspace.shared.activateFileViewerSelecting([destinationURL])
                                } label: {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                }
                            }.buttonStyle(.borderless)
                        } else {
                            VStack {
                                Spacer()
                                Button {
                                    downloadManager.cancelDownload(task.id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                }
                            }.buttonStyle(.borderless)
                        }
                    }
                    
                    if task.destinationURL == nil {
                        
                        ZStack(alignment: .leading) {
                            Rectangle().frame(width: CGFloat(min(task.progress * 316, 316)), height: 3).foregroundColor(.accentColor)
                            Rectangle().frame(width: 316, height: 3).foregroundColor(.secondary)
                        }.cornerRadius(10).padding(1)
                        HStack {
                            //                    Text("12 MB/s")
                            Spacer()
                            Text("swui.downloadsizes \(task.formattedCurrentSize) / \(task.formattedExpectedSize)")
                        }.font(.caption).foregroundStyle(.secondary)
                        
                    }
                }
                
            }.padding(15)
        }.frame(maxHeight: 700)
//            .padding(.horizontal, 5)
    }
}
#endif
