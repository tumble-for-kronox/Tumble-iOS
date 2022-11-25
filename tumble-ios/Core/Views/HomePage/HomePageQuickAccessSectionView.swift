//
//  HomePageQuickAccess.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct QuickAccessOption: Identifiable, Equatable {
    static func == (lhs: QuickAccessOption, rhs: QuickAccessOption) -> Bool {
        return lhs.id == rhs.id
    }
    
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
                        .font(.title2)
                        .foregroundColor(Color("OnBackground"))
                        .bold()
                        .padding(.leading, 20)
                    Spacer()
                    Image(systemName: image)
                        .font(.system(size: 20))
                        .padding(.trailing, 20)
                        .foregroundColor(Color("OnBackground"))
                }
                
            }
            .padding(.bottom, 5)
            VStack {
                ForEach(quickAccessOptions, id: \.id) { option in
                    HomePageQuickAccessOptionView(option: option, isLast: option == quickAccessOptions.last)
                    
                }
            }
            .padding(.bottom, 15)
            .padding(.top, 25)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .frame(maxWidth: .infinity)
            .background(Color("SurfaceColor"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .padding(.horizontal, 20)
        }
        
    }
}
