//
//  CourseColorPicker.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import SwiftUI

struct CourseColorPicker: View {
    @State private var bgColor = Color.red

    var body: some View {
        VStack {
            ColorPicker("Set the background color", selection: $bgColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bgColor)
    }
}

struct CourseColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        CourseColorPicker()
    }
}
