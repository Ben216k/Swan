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
                VStack() {
                    Text("Swan")
                        .font(Font.title2.bold())
                    Text("v\(SwanApp.version) (\(SwanApp.build))")
                        .font(.subheadline)
                }
            }.padding(.bottom, 10)
            Text("Currently, Swan is in private beta. Please expect bugs, so that you can report those bugs! Thanks for helping build this app into what it isn't quite yet today!")
                .multilineTextAlignment(.center)
        }.padding().padding(.horizontal, 15)
            .frame(width: 425, height: 225)
    }
}

#Preview {
    AboutSwanView()
}
