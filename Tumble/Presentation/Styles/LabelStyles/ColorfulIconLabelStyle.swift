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
                .padding(.leading, 10)
        } icon: {
            configuration.icon
                .font(.system(size: 14))
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 7).frame(width: 28, height: 28).foregroundColor(color))
        }
    }
}
