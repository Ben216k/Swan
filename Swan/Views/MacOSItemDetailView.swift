// 
//  MacOSItemDetailView.swift - Swan
// 
//  Created by Ben216k on 8/9/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct MacOSItemDetailView: View {
    
    @EnvironmentObject var cache: SUCache
    @EnvironmentObject var downloadManager: DownloadManager
    
    @Binding var selection: String?
    @State var uncollapsedSections: [String] = ["InstallAssistant.pkg"]
    
    var body: some View {
        if let product = cache.products[selection ?? "unused"] as? SUMacOSPackage {
            List {
                
                // MARK: - Header
                
                HStack {
                    product.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45)
                        .cornerRadius(100)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading) {
                        Text("macOS " + product.osName + " " + product.version)
                            .font(.title2.bold())
                        Text("swui.macospackage.linetwo \(product.buildNumber) \(product.postDateFormatted)")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - Identification Information
                
                Section("swui.identificationinformation") {
                    FakeTableItem(title: "swui.releasename", value: product.osName)
                    FakeTableItem(title: "swui.version", value: product.version)
                    FakeTableItem(title: "swui.buildnumber", value: product.buildNumber)
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
                
                ForEach(product.packages) { package in
                    Section(header: CollapsibleHeader(package.name, isCollapsed: binding(for: package.name))) {
                        if uncollapsedSections.contains(package.name) {
                            PackagePieces(package: package) { (url) in
                                Task {
                                    try? await downloadManager.startDownload(from: url, title: "macOS " + product.osName + " " + product.version, specific: "Build \(product.buildNumber) | \(url.lastPathComponent)", image: product.imageName)
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
                uncollapsedSections.contains(id)
            },
            set: { newValue in
                if newValue {
                    if !uncollapsedSections.contains(id) {
                        uncollapsedSections.append(id)
                    }
                } else {
                    if let index = uncollapsedSections.firstIndex(of: id) {
                        uncollapsedSections.remove(at: index)
                    }
                }
            }
        )
    }
}

struct CollapsibleHeader: View {
    
    let title: String
    @Binding var isCollapsed: Bool
    
    var body: some View {
        
        HStack {
            Text(title)
            Spacer()
            Button { isCollapsed.toggle() } label: {
                Image(systemName: !isCollapsed ? "chevron.forward" : "chevron.down")
            }.buttonStyle(.borderless)
        }
        
        
    }
    
    init(_ title: LocalizedStringResource, isCollapsed: Binding<Bool>) {
        self.title = String(localized: title)
        self._isCollapsed = isCollapsed
    }
    
    init(_ title: String, isCollapsed: Binding<Bool>) {
        self.title = title
        self._isCollapsed = isCollapsed
    }
    
}
