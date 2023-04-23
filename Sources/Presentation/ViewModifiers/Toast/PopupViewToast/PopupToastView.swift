//
//  PopupToastView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct PopupToastView: View {
    let title: String
    var body: some View {
        Text(title)
            .popupToast()
    }
}
