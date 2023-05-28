//
//  LoginButtonStyle.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-25.
//

import Foundation
import SwiftUI

struct WideAnimatedButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = .primary) {
        self.color = color
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(color)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
