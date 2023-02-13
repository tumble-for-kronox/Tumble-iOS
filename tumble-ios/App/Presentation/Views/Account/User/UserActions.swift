//
//  UserOptions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserActions<Content : View>: View {
    
    let content: Content
    let title: String
    let image: String
    
    init(title: String, image: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.image = image
        self.content = content()
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Image(systemName: image)
                Text(title)
                    .font(.system(size: 16, design: .rounded))
                VStack {
                    Divider()
                        .overlay(Color.onBackground)
                        .padding(.leading)
                }
            }
            content
        }
        .padding(25)
    }
}
