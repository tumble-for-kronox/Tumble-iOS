//
//  OnBoardingViewBuilder.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct OnBoardingViewBuilder<Content : View>: View {
    let header: String
    let subHeader: String
    let content: Content
    
    init(header: String, subHeader: String, @ViewBuilder content: () -> Content) {
        self.header = header
        self.subHeader = subHeader
        self.content = content()
    }
    
    var body: some View {
        VStack (alignment: .center) {
            Text(header)
                .mainHeaderBoldPrimary()
            
            VStack (alignment: .center) {
                Text(subHeader)
                    .subHeaderBold()
                    .multilineTextAlignment(.center)
                VStack {
                    content
                }
                .padding(.top, 25)
            }
            .padding(.top, 30)
            Spacer()
        }
        .padding([.leading, .trailing], 10)
        .padding(.top, 5)
    }
}

