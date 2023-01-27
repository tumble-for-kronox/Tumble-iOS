//
//  PreviewCardBannerView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import SwiftUI

struct PreviewCardBannerView: View {
    let color: Color
    let timeSpan: String
    let isSpecial: Bool
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(color)
                .frame(height: 7)
            Text(timeSpan)
                .font(.subheadline)
                .foregroundColor(Color("OnSurface"))
            Spacer()
            if isSpecial {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.title3)
                    .foregroundColor(Color("OnSurface"))
                    .padding(.trailing, 15)
            }
        }
        .padding(.top, 20)
        .padding(.leading, 25)
        .padding(.bottom, 10)
    }
}

