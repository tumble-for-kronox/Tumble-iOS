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
        HStack {
            HStack (spacing: 0) {
                Button(action: option.onClick, label: {
                    Image(systemName: option.image)
                        .font(.system(size: 20))
                        .frame(width: 25, height: 5)
                        .foregroundColor(.white)
                        .padding(20)
                        .background(option.iconColor)
                        .clipShape(Circle())
                        
                    Text(option.title)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.trailing, 15)
                        .padding(.leading, 2.5)
                        
                })
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(12)
                
            }
            .background(option.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .padding(5)
            Spacer()
        }
        
    }
}
