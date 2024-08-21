// 
//  ProductDetailView.swift - Swan
// 
//  Created by Ben216k on 8/19/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var cache: SUCache
    @EnvironmentObject var downloadManager: DownloadManager

    @Binding var selection: String?
    @State var uncollapsedSections: [String] = ["InstallAssistant.pkg"]

    var body: some View {
        if let product = cache.products[selection ?? "unused"] {
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
                        Text(product.downloadTitleText)
                            .font(.title2.bold())
                        Text(product.downloadSubtitleText + " \(product.postDateFormatted)")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }

                // MARK: - Identification Information

                Section("swui.identificationinformation") {
                    
                    if let macosProduct = product as? SUMacOSPackage{
                        FakeTableItem(title: "swui.releasename", value: macosProduct.osName)
                        FakeTableItem(title: "swui.version", value: macosProduct.version)
                        FakeTableItem(title: "swui.buildnumber", value: macosProduct.buildNumber)
                    } else {
                        FakeTableItem(title: "swui.version", value: product.version)
                    }
                    FakeTableItem(title: "swui.productid", value: product.key)
                    FakeTableItem(title: "swui.postdate", value: product.postDateFormattedLong)
                    if let deferredSUEnablementDateFormattedLong = product.deferredSUEnablementDateFormattedLong {
                        FakeTableItem(title: "swui.deferredsuenablementdate", value: deferredSUEnablementDateFormattedLong)
                    }
                    if let serverMetadataURLString = product.serverMetadataURL, let url = URL(string: serverMetadataURLString) {
                        SMDViewTeaser(url: url, serverMetadata: product.serverMetadata) { url in
                            startDownload(url: url)
                        }
                    }
                }

                // MARK: - Extended Metadata

                if let extendedMetaInfo = product.extendedMetaInfo {
                    if extendedMetaInfo.containsAnythingButInstallAssistant {
                        Section("swui.extendedmetadata") {
                            if let productVersion = extendedMetaInfo.productVersion {
                                FakeTableItem(title: "swui.extendedmetadata.productversion", value: productVersion)
                            }
                            if let productType = extendedMetaInfo.productType {
                                FakeTableItem(title: "swui.extendedmetadata.producttype", value: productType)
                            }
                            if let autoUpdate = extendedMetaInfo.autoUpdate {
                                FakeTableItem(title: "swui.extendedmetadata.autoupdate", value: autoUpdate)
                            }
                            if let autoUpdate = extendedMetaInfo.bridgeOSPredicateProductOrdering {
                                FakeTableItem(title: "swui.extendedmetadata.bridgeOSPredicateProductOrdering", value: autoUpdate)
                            }
                            if let autoUpdate = extendedMetaInfo.bridgeOSSoftwareUpdateEventRecordingServiceURL {
                                FakeTableItem(title: "swui.extendedmetadata.bridgeOSSoftwareUpdateEventRecordingServiceURL", value: autoUpdate)
                            }
                        }
                    }
                    if let installAssistantPackageIdentifiers = extendedMetaInfo.installAssistantPackageIdentifiers {
                        Section(header: CollapsibleHeader(key: "swui.iapackageidentifiers", isCollapsed: binding(for: "swui.iapackageidentifiers"))) {
                            if uncollapsedSections.contains("swui.iapackageidentifiers") {
                                if let buildManifest = installAssistantPackageIdentifiers.buildManifest {
                                    FakeTableItem(title: "swui.extendedmetadata.buildManifest", value: buildManifest)
                                }
                                if let info = installAssistantPackageIdentifiers.info {
                                    FakeTableItem(title: "swui.extendedmetadata.info", value: info)
                                }
                                if let installInfo = installAssistantPackageIdentifiers.installInfo {
                                    FakeTableItem(title: "swui.extendedmetadata.installInfo", value: installInfo)
                                }
                                if let osInstall = installAssistantPackageIdentifiers.osInstall {
                                    FakeTableItem(title: "swui.extendedmetadata.osInstall", value: osInstall)
                                }
                                if let sharedSupport = installAssistantPackageIdentifiers.sharedSupport {
                                    FakeTableItem(title: "swui.extendedmetadata.sharedSupport", value: sharedSupport)
                                }
                                if let updateBrain = installAssistantPackageIdentifiers.updateBrain {
                                    FakeTableItem(title: "swui.extendedmetadata.updateBrain", value: updateBrain)
                                }
                            }
                        }
                    }
                   
                }

                // MARK: - Distributions (macOS Specific)

                Section(header: CollapsibleHeader(key: "swui.distributions",
                                                   isCollapsed: binding(for: "Distributions"))) {
                    if uncollapsedSections.contains("Distributions") {
                        FakeTableItem(title: "swui.distributionscount", value: "\(product.distributions.count)")
                        ForEach(Array(product.distributions.keys), id: \.self) { distro in
                            if let distribution = product.distributions[distro],
                               let url = URL(string: distribution) {
                                DistributionRow(name: distro, url: url, product: product)
                            }
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
                                for package in product.packages {
                                    startDownload(url: URL(string: package.url)!)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.down.circle")
                        }.buttonStyle(.borderless)
                    }.font(.subheadline)
                }

                ForEach(product.packages) { package in
                    Section(header: CollapsibleHeader(package.name, isCollapsed: binding(for: package.name))) {
                        if uncollapsedSections.contains(package.name) {
                            PackagePieces(product: product, package: package)
                        }
                    }
                }
            }
            .listStyle(.inset)
            .onAppear {
                if product.type == .safari && !uncollapsedSections.contains(product.packages.first?.name ?? "What") {
                    uncollapsedSections.append(product.packages.first?.name ?? "What")
                }
            }
            .onChange(of: selection) { _ in
                if product.type == .safari && !uncollapsedSections.contains(product.packages.first?.name ?? "What") {
                    uncollapsedSections.append(product.packages.first?.name ?? "What")
                }
            }
        } else if selection == nil || selection?.isEmpty == true {
            Text("swui.noitemselected")
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

    private func startDownload(url: URL?) {
        guard let url = url else { return }
        if let product = cache.products[selection ?? "unused"] {
            Task {
                try? await downloadManager.startDownload(
                    from: url,
                    title: product.downloadTitleText,
                    specific: "\(product.downloadSubtitleText) | \(url.lastPathComponent)",
                    image: product.imageName
                )
            }
        }
    }
}
