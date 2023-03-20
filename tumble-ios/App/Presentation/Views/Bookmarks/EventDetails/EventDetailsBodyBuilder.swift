//
//  EventDetailsBodyBuilder.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct EventDetailsBodyBuilder<Content : View>: View {
    let title: String
    let image: String
    let content: Content
    
    init(title: String, image: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.image = image
        self.content = content()
    }
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 0) {
                HStack (alignment: .center, spacing: 10) {
                    Image(systemName: image)
                        .font(.system(size: 20))
                        .foregroundColor(.onSurface)
                    Text(title)
                        .font(.system(size: 18))
                        .bold()
                        .foregroundColor(.onBackground)
                    
                }
                .padding(.bottom, 5)
                VStack (alignment: .leading) {
                    content
                }
                .padding(.top, 7.5)
            }
            Spacer()
        }
        .frame(minWidth: UIScreen.main.bounds.width - 60)
        .padding(15)
        .background(Color.surface)
        .cornerRadius(15)
        .padding(.top, 10)
        .padding(.horizontal, 15)
    }
}
