// 
//  SMDView.swift - Swan
// 
//  Created by Ben216k on 8/19/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct SMDViewTeaser: View {
    
    let url: URL
    let serverMetadata: SUServerMetadata?
    let downloadURL: (URL) -> ()
    @State var showSMDDetails = false
    
    var body: some View {
        HStack {
            Text("swui.smd.url")
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            Spacer()
            Text(url.absoluteString)
                .lineLimit(1)
                .truncationMode(.head)
                .frame(width: 125)
            Button {
                downloadURL(url)
            } label: {
                Image(systemName: "arrow.down.circle")
            }.buttonStyle(.borderless)
            Button {
                SwanApp.copyString(url.absoluteString)
            } label: {
                Image(systemName: "doc.on.doc")
            }.buttonStyle(.borderless)
            if let serverMetadata, let localization = serverMetadata.localizations["English"] {
                Button {
                    showSMDDetails.toggle()
                } label: {
                    Image(systemName: "eye")
                }.buttonStyle(.borderless)
                    .popover(isPresented: $showSMDDetails) {
                        SMDFullView(localization: localization, serverMetadata: serverMetadata)
                    }
            }
        }.font(.subheadline)
    }
    
}

struct SMDFullView: View {
    
    let localization: SUSMDLocalization
    let serverMetadata: SUServerMetadata
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("swui.smd.titleformatted \(localization.title) \(serverMetadata.version)")
                .font(.headline)
            Text(localization.serverComment)
                .font(.subheadline)
            if let descriptionHTML = localization.descriptionHTML {
                HTMLRenderer(htmlString: descriptionHTML)
                    .frame(height: 200)
            }
            if let client = serverMetadata.platforms.client {
                Text("Client Platforms: \(client.joined(separator: ", "))")
            }
            if let server = serverMetadata.platforms.server {
                Text("Server Platforms: \(server.joined(separator: ", "))")
            }
            
        }.padding(15).frame(width: 400)
    }
    
}
    
