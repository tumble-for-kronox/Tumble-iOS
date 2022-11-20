//
//  HomePageContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct HomePageContent: View {
    let title: String
    let image: String
    var onClick: () -> Void
    var body: some View {
        VStack {
            Button(action: onClick, label: {
                Image(systemName: image)
                    .font(.system(size: 23))
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color("PrimaryColor").opacity(0.85))
                    .clipShape(Circle())
                    
            })
            .padding(.bottom, 30)
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(Color("SecondaryColor"))
        }
        .padding(.bottom, 25)
    }
}
