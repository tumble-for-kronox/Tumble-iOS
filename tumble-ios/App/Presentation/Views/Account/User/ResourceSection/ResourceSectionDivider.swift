//
//  UserOptions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct ResourceSectionDivider<Content : View>: View {
    
    let content: Content
    let title: String
    let image: String
    let onBook: (() -> Void)?
    let destination: AnyView?
    
    init(title: String, image: String, destination: AnyView? = nil, onBook: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.image = image
        self.onBook = onBook
        self.destination = destination
        self.content = content()
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 20))
                    .foregroundColor(.onBackground)
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.onBackground)
                VStack (spacing: 0) {
                    Divider()
                        .overlay(Color.onBackground)
                        .padding([.leading, .trailing], 5)
                }
                if let destination = destination {
                    NavigationLink(destination: destination, label: {
                        HStack {
                            Text("Book")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    })
                    
                }
            }
            .padding(.bottom, 15)
            content
        }
        .padding(.vertical, 25)
        .padding(.horizontal, 17)
    }
}
