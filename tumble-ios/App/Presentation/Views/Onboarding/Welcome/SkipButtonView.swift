//
//  SkipButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

typealias OnClickSkip = () -> Void

struct SkipButtonView: View {
    let onClickSkip: OnClickSkip
    var body: some View {
        Button(action: onClickSkip) {
                Text("Skip")
                    .font(.system(size: 20))
                    .bold()
                    .padding()
                    .foregroundColor(Color("OnPrimary"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 150)
                )
            }
            .frame(width: 150)
            .background(Color("PrimaryColor"))
            .cornerRadius(10)
    }
}
