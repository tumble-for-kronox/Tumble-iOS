//
//  ColorfulIconLabelStyle.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-06.
//

import Foundation
import SwiftUI

struct ColorfulIconLabelStyle: LabelStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
                .foregroundColor(.onSurface)
                .padding(.leading, 20)
        } icon: {
            configuration.icon
                .frame(width: 2, height: 2)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .frame(width: 30, height: 30)
                        .foregroundColor(color)
                )
        }
        .padding(.leading, 10)
    }
}
