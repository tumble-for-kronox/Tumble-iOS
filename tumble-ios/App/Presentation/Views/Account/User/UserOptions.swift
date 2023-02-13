//
//  UserOptions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserOptions<Content : View>: View {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Image(systemName: "gearshape")
                Text("User options")
                    .font(.system(size: 16, design: .rounded))
                VStack {
                    Divider()
                        .overlay(Color.onBackground)
                        .padding()
                }
            }
            content
        }
        .padding()
    }
}

struct UserOptions_Previews: PreviewProvider {
    static var previews: some View {
        UserOptions(content: {
            Text("Hello world")
        })
    }
}
