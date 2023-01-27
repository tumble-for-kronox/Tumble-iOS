//
//  CustomProgressView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/19/22.
//

import SwiftUI

struct CustomProgressView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color("PrimaryColor")))
            .scaleEffect(1.5, anchor: .center)
    }
}
