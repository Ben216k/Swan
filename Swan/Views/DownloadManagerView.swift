// 
//  DownloadManagerView.swift - Swan
// 
//  Created by Ben216k on 8/10/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct DownloadManagerView: View {
    @EnvironmentObject var cache: SUCache
    @EnvironmentObject var downloadManager: DownloadManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("Downloads")
                    .padding(.bottom, 10)
                Spacer()
            }
            
            if downloadManager.downloadTasks.isEmpty {
                Text("No Current Downloads")
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
                        }
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
                        Text("\(task.formattedCurrentSize) / \(task.formattedExpectedSize)")
                    }.font(.caption).foregroundStyle(.secondary)
                    
                }
            }
            
        }.padding(15)
//            .padding(.horizontal, 5)
    }
}
