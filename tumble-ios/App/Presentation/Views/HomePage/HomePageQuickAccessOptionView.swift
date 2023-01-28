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
                            .homePageOptionIcon(color: option.iconColor)
                            
                        Text(option.title)
                            .homePageOption()
                            
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 14))
                            .foregroundColor(Color("OnSurface"))
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
