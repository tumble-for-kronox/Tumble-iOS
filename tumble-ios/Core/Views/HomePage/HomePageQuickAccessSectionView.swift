//
//  HomePageQuickAccess.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct QuickAccessOption: Identifiable {
    let id: QuickAccessId
    let title: String
    let image: String
    let onClick: () -> Void
    let backgroundColor: Color
    let iconColor: Color
}

struct HomePageQuickAccessSectionView: View {
    let title: String
    let image: String
    let quickAccessOptions: [QuickAccessOption]
    var body: some View {
        VStack {
            VStack (alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.title)
                        .foregroundColor(Color("SecondaryColor"))
                        .bold()
                        .padding(.leading, 20)
                    Spacer()
                    Image(systemName: image)
                        .font(.system(size: 26))
                        .padding(.trailing, 20)
                        .foregroundColor(Color("SecondaryColor"))
                }
                Divider()
                    .background(.black)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
            }
            .padding(.top, 25)
            VStack {
                ForEach(quickAccessOptions, id: \.id) { option in
                    HomePageQuickAccessOptionView(option: option)
                }
            }
            .padding(.top, 15)
            .padding(.leading, 10)
        }
    }
}
