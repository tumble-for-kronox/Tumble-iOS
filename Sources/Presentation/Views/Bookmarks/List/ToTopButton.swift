//
//  ToTopButton.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-02.
//

import SwiftUI

struct ToTopButton: View {
    var buttonOffsetX: CGFloat
    var value: ScrollViewProxy
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                value.scrollTo("bookmarkScrollView", anchor: .top)
            }
        }, label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.onPrimary)
                .padding(15)
                .background(Color.primary)
                .clipShape(Rectangle())
                .cornerRadius(40)
        })
        .buttonStyle(ToTopButtonStyle())
        .padding()
        .offset(x: buttonOffsetX)
    }
}
