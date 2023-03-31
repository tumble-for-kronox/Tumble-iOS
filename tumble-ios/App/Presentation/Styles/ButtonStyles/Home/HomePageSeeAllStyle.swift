//
//  HomePageSeeAllStyle.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import Foundation
import SwiftUI

struct HomePageSeeAllStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
