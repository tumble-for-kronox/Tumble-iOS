//
//  HomePageLinkSectionView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/28/22.
//

import SwiftUI

struct ExternalLink: Identifiable, Equatable {
    
    static func == (lhs: ExternalLink, rhs: ExternalLink) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: ExternalLinkId
    let title: String
    let image: String
    let backgroundColor: Color
    let iconColor: Color
    let url: String
}

enum ExternalLinkId: String {
    case canvas = "canvas"
    case ladok = "ladok"
    case kronox = "kronox"
    case university = "university"
}

struct HomePageLinkSectionView: View {
    let title: String
    let image: String
    let links: [ExternalLink]
    var body: some View {
        VStack {
            VStack (alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.title2)
                        .foregroundColor(Color("OnBackground"))
                        .bold()
                        .padding(.leading, 15)
                    Spacer()
                    Image(systemName: image)
                        .optionBigIcon()
                }
                
            }
            .padding(.bottom, 5)
            VStack {
                ForEach(links, id: \.id) { link in
                    if URL(string: link.url) != nil {
                        HomePageLinkOptionView(link: link, isLast: link == links.last)
                    }
                }
            }
            .padding(.bottom, 15)
            .padding(.top, 15)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .background(Color("SurfaceColor"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .padding(.horizontal, 15)
        }
    }
}
