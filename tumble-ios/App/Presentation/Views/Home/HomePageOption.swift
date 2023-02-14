//
//  HomePageEventView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import SwiftUI

struct HomePageOption: View {
    
    let titleText: String
    let bodyText: String
    let image: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap, label: {
            HStack {
                HStack {
                    Image(systemName: image)
                        .font(.system(size: 40))
                        .foregroundColor(.primary)
                        .frame(width: 60)
                        .padding(10)
                    VStack (alignment: .leading, spacing: 0) {
                        Text(titleText)
                            .font(.system(size: 22, design: .rounded))
                            .foregroundColor(.onSurface)
                            .bold()
                            .padding(.bottom, 5)
                        Text(bodyText)
                            .foregroundColor(.onSurface)
                            .font(.system(size: 18, design: .rounded))
                    }
                    .frame(minHeight: 60, alignment: .center)
                    .padding(.trailing, 10)
                    .padding([.top, .bottom], 10)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))
                        .foregroundColor(.onSurface.opacity(0.8))
                        .padding(.trailing, 15)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, alignment: .center)
                .background(Color.surface)
                .cornerRadius(10)
                .padding([.bottom, .top], 10)
                
            }
        })
    }
}
