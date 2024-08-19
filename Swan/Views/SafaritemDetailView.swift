// 
//  SafariItemDetailView.swift - Swan
//
//  Created by Ben216k on 8/12/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct SafariItemDetailView: View {
    
    @EnvironmentObject var cache: SUCache
    @EnvironmentObject var downloadManager: DownloadManager
    
    @Binding var selection: String?
    @State var collapsedSections: [String] = []
    
    var body: some View {
        if let product = cache.products[selection ?? "unused"] as? SUSafariResolved {
            List {
                
                // MARK: - Header
                
                HStack {
                    Image("SafariCircle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45)
                        .cornerRadius(100)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading) {
                        Text("Safari " + product.version)
                            .font(.title2.bold())
                        Text("swui.safaripackage.linetwo \(product.macOSVersion) \(product.postDateFormatted)")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - Identification Information
                
                Section("swui.identificationinformation") {
                    FakeTableItem(title: "swui.version", value: product.version)
                    FakeTableItem(title: "swui.macosversion", value: product.macOSVersion)
                    FakeTableItem(title: "swui.productid", value: product.key)
                    FakeTableItem(title: "swui.fullinstallerposted", value: product.postDateFormattedLong)
                    if let deferredSUEnablementDateFormattedLong = product.deferredSUEnablementDateFormattedLong {
                        FakeTableItem(title: "swui.deferredsuenablementdate", value: deferredSUEnablementDateFormattedLong)
                    }
                }
                
                // MARK: - Extended Metadata
                
                if let extendedMetaInfo = product.extendedMetaInfo {
                    if extendedMetaInfo.containsAnythingButInstallAssistant {
                        Section("swui.extendedmetadata") {
                            if let productVersion = extendedMetaInfo.productVersion { FakeTableItem(title: "swui.extendedmetadata.productversion", value: productVersion) }
                            if let productType = extendedMetaInfo.productType { FakeTableItem(title: "swui.extendedmetadata.producttype", value: productType) }
                            if let autoUpdate = extendedMetaInfo.autoUpdate { FakeTableItem(title: "swui.extendedmetadata.autoupdate", value: autoUpdate) }
                        }
                    }
                }
                
                
                // MARK: - Packages

                Section("swui.packages") {
                    FakeTableItem(title: "swui.packagecount", value: "\(product.packages.count)")
                    HStack {
                        Text("swui.downloadallpackages")
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Button {
                            Task {
                                do {
                                    let _ = try await withThrowingTaskGroup(of: Void.self) { group in
                                        for package in product.packages {
                                            group.addTask {
                                                let _ = try await downloadManager.startDownload(from: URL(string: package.url)!, title: "Safari " + product.version, specific: "For \(product.macOSVersion) | \(URL(string: package.url)!.lastPathComponent)", image: "SafariCircle")
                                            }
                                        }
                                        try await group.waitForAll()
                                    }
                                    // Handle successful downloads
                                } catch {
                                    // Handle errors
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.down.circle")
                        }.buttonStyle(.borderless)
                    }.font(.subheadline)
                }
                
                ForEach(product.packages) { package in
                    Section(header: CollapsibleHeader(package.name, isCollapsed: binding(for: package.name))) {
                        if !collapsedSections.contains(package.name) {
                            PackagePieces(package: package) { (url) in
                                Task {
//                                    try? await downloadManager.startDownload(from: url, title: "macOS " + product.osName + " " + product.version, specific: "Build \(product.buildNumber) | \(url.lastPathComponent)", image: product.imageName)
                                    try? await downloadManager.startDownload(from: URL(string: package.url)!, title: "Safari " + product.version, specific: "For \(product.macOSVersion) | \(URL(string: package.url)!.lastPathComponent)", image: "SafariCircle")
                                }
                            }
                        }
                    }
                }
            }.listStyle(.inset)
        } else if selection == nil || selection?.isEmpty == true {
            Text("swui.noitemselected")
        } else if cache.products[selection ?? "unused"] != nil {
            Text("swui.nonmacospackageselected")
        } else {
            Text("swui.invalidproductselected")
        }
    }
    
    private func binding(for id: String) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                !collapsedSections.contains(id)
            },
            set: { newValue in
                if newValue {
                    if let index = collapsedSections.firstIndex(of: id) {
                        collapsedSections.remove(at: index)
                    }
                } else {
                    if !collapsedSections.contains(id) {
                        collapsedSections.append(id)
                    }
                }
            }
        )
    }
}
