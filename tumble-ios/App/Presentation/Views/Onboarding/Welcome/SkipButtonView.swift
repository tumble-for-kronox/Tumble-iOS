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
                    .onPrimaryMediumBold()
            }
            .frame(width: 140)
            .background(Color("PrimaryColor"))
            .cornerRadius(10)
    }
}
