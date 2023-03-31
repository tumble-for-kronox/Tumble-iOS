//
//  LoginButtonStyle.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-25.
//

import Foundation
import SwiftUI

struct WideAnimatedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color("PrimaryColor"))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
