//
//  HomePageLinkOptionView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/28/22.
//

import SwiftUI

struct HomePageLinkOptionView: View {
    let link: ExternalLink
    let isLast: Bool
    var body: some View {
        Link(destination: URL(string: link.url)!) {
            VStack {
                HStack (spacing: 0) {
                    HStack {
                        Image(systemName: link.image)
                            .homePageOptionIcon(color: link.iconColor)
                            
                        Text(link.title)
                            .homePageOption()
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 14))
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
