//
//  InfoLoadingView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct InfoLoading: View {
    let title: String
    var body: some View {
        VStack(alignment: .center) {
            CustomProgressIndicator()
                .padding(.bottom, 15)
            Text(title)
                .info()
                .multilineTextAlignment(.center)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
        )
        .background(Color.background)
    }
}
