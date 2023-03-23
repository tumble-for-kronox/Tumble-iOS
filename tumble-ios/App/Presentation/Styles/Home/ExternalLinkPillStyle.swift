//
//  ExternalLinkPillStyle.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-12.
//

import Foundation
import SwiftUI

struct ExternalLinkPillStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.all, 10)
            .background(Color.surface)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
