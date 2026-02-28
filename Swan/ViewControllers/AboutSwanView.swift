// 
//  AboutSwanView.swift - Swan
// 
//  Created by Ben216k on 9/1/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI

struct AboutSwanView: View {
    var body: some View {
        VStack {
            HStack {
                Image("SwanIcon")
                    .resizable()
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text("Swan")
                        .font(Font.title2.bold())
                    Text("v\(SwanApp.version) (\(SwanApp.build))")
                        .font(.subheadline)
                }.padding(.leading, 5)
            }.padding(.bottom, 10)
            Text("swui.about.betadisclaimer")
                .multilineTextAlignment(.center)
        }.padding().padding(.horizontal, 15)
            .frame(width: 425, height: 225)
    }
}

#Preview {
    AboutSwanView()
}
