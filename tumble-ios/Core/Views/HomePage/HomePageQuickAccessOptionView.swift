//
//  HomePageContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct HomePageQuickAccessOptionView: View {
    let option: QuickAccessOption
    let isLast: Bool
    var body: some View {
        Button(action: option.onClick) {
            VStack {
                HStack (spacing: 0) {
                    HStack {
                        Image(systemName: option.image)
                            .font(.largeIconFont)
                            .frame(width: 17, height: 17)
                            .padding(15)
                            .foregroundColor(Color("OnPrimary"))
                            .background(option.iconColor)
                            .clipShape(RoundedRectangle(cornerRadius: 7.5))
                        Text(option.title)
                            .font(.subheadline)
                            .foregroundColor(Color("OnSurface"))
                            .padding(.trailing, 15)
                            .padding(.leading, 15)
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 12))
                            .foregroundColor(Color("OnSurface").opacity(0.75))
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                if !isLast {
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(5)
    }
}
