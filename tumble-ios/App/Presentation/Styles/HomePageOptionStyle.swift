//
//  HomePageOptionStyle.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/14/23.
//

import Foundation
import SwiftUI

struct HomePageOptionStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, alignment: .center)
            .background(Color.surface)
            .cornerRadius(10)
            .padding([.bottom, .top], 10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
