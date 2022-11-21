//
//  HomePageContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct HomePageQuickAccessOptionView: View {
    let option: QuickAccessOption
    var body: some View {
        Button(action: option.onClick) {
            HStack (spacing: 0) {
                Image(systemName: option.image)
                    .font(.system(size: 21))
                    .frame(width: 10)
                    .padding(20)
                    .foregroundColor(Color("BackgroundColor"))
                    .background(option.iconColor)
                    .clipShape(Circle())
                
                Text(option.title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.trailing, 15)
                    .padding(.leading, 15)
                
            }
            .padding(.leading, 12.5)
            .padding(.top, 2.5)
            .padding(.bottom, 2.5)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
        }
        .frame(maxWidth: .infinity)
        .background(option.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
        .padding(.trailing, 10)
        .padding(.leading, 10)
        .padding(.bottom, 2.5)
    }
}
