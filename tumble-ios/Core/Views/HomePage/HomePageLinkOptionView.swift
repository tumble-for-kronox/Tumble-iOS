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
                            .font(.system(size: 17))
                            .frame(width: 17, height: 17)
                            .padding(15)
                            .foregroundColor(Color("OnPrimary"))
                            .background(link.iconColor)
                            .clipShape(RoundedRectangle(cornerRadius: 7.5))
                        Text(link.title)
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
