// 
//  PackagePieces.swift - Swan
// 
//  Created by Ben216k on 8/10/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct PackagePieces: View {
    
    @EnvironmentObject var downloadManager: DownloadManager
        
    let product: any SUProductResolved
    let package: SUPackage
    
    var body: some View {
        Group {
            // MARK: URL
            
            HStack {
                Text("swui.package.url")
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(package.url)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .frame(width: 125)
                Button {
                    downloadURL(URL(string: package.url)!)
                } label: {
                    Image(systemName: "arrow.down.circle")
                }.buttonStyle(.borderless)
                Button {
                    SwanApp.copyString(package.url)
                } label: {
                    Image(systemName: "doc.on.doc")
                }.buttonStyle(.borderless)
            }
            
            if let digest = package.digest {
                HStack {
                    Text("swui.package.digest")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(digest)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 125)
                    Button {
                        SwanApp.copyString(digest)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }.buttonStyle(.borderless)
                }
            }
            
            HStack {
                Text("swui.package.size")
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(package.formattedSize)
                    .lineLimit(1)
            }
            
            if let integrityDataURL = package.integrityDataURL {
                HStack {
                    Text("swui.package.integritydataurl")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(integrityDataURL)
                        .lineLimit(1)
                        .truncationMode(.head)
                        .frame(width: 125)
                    Button {
                        downloadURL(URL(string: integrityDataURL)!)
                    } label: {
                        Image(systemName: "arrow.down.circle")
                    }.buttonStyle(.borderless)
                    Button {
                        SwanApp.copyString(integrityDataURL)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }.buttonStyle(.borderless)
                }
                
                if let formattedIntegritySize = package.formattedIntegritySize {
                    HStack {
                        Text("swui.package.integritydatasize")
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(formattedIntegritySize)
                            .lineLimit(1)
                    }
                }
            }
            
            if let metadataURL = package.metadataURL {
                HStack {
                    Text("swui.package.metadataurl")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(metadataURL)
                        .lineLimit(1)
                        .truncationMode(.head)
                        .frame(width: 125)
                    Button {
                        downloadURL(URL(string: metadataURL)!)
                    } label: {
                        Image(systemName: "arrow.down.circle")
                    }.buttonStyle(.borderless)
                    Button {
                        SwanApp.copyString(metadataURL)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }.buttonStyle(.borderless)
                }
            }
        }
        .font(.subheadline)
    }
    
    func downloadURL(_ url: URL) {
        Task {
            try? await downloadManager.startDownload(from: url, title: product.downloadTitleText, specific: "\(product.downloadSubtitleText) | \(url.lastPathComponent)", image: product.imageName)
        }
    }
}
