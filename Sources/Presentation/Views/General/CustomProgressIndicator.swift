//
//  CustomProgressView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/19/22.
//

import SwiftUI

struct CustomProgressIndicator: View {
    let tint: Color
    
    init(tint: Color = .primary) {
        self.tint = tint
    }
    
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: tint))
            .scaleEffect(1, anchor: .center)
    }
}
