//
//  BookButtonStyle.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/23/23.
//

import Foundation
import SwiftUI

struct BookButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 85, maxHeight: 50)
            .background(Color.primary)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
