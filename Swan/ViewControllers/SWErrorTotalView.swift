// 
//  SWErrorTotalView.swift - Swan
// 
//  Created by Ben216k on 8/12/24
//  Copyright (c) Ben216k (under 216k License)
//

import SwiftUI

struct SWErrorTotalView: View {
    
    let error: SWError
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("swui.error.loadingcatalogs")
                .bold()
            Text(error.localizedDescription)
            Rectangle().opacity(0.00000001)
        }.padding(20)
        
    }
    
}

#Preview {
    SWErrorTotalView(error: .init(source: "SUCache().life", id: "swerror.foundation.unknown", data: "Please help me."))
        .frame(width: 350, height: 400)
}
