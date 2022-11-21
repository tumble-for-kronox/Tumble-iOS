//
//  PopupToastView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct PopupToastView: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.mediumFont)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 45, alignment: .leading)
            .background(Color("PrimaryColor").opacity(0.75))
            .cornerRadius(10)
            .padding(.bottom, 165)
            .padding(.leading, 15)
            .padding(.trailing, 15)
    }
}
