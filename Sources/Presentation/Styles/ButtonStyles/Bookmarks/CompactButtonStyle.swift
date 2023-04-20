//
//  HomePageEventButtonStyle.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-20.
//

import Foundation
import SwiftUI

struct CompactButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    init(backgroundColor: Color = Color.surface) {
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100, alignment: .center)
            .background(backgroundColor)
            .cornerRadius(20)
            .padding(.bottom, 10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
