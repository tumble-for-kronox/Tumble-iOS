//
//  HomePageHeader.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import SwiftUI

struct HomePageHeader: View {
    
    @ObservedObject var parentViewModel: HomeViewModel
    @Binding var domain: String?
    @Binding var collapsedHeader: Bool
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 0) {
                if !collapsedHeader {
                    Text(getCurrentDate())
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)
                }
                HStack (alignment: .center, spacing: 10) {
                    if collapsedHeader {
                        Text(getCurrentDate(truncate: true))
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    ExternalLinkPill(
                        title: domain?.uppercased() ?? "",
                        image: "link",
                        url: parentViewModel.makeUniversityUrl(),
                        collapsedHeader: $collapsedHeader)
                    ExternalLinkPill(
                        title: "Canvas",
                        image: "link",
                        url: parentViewModel.makeCanvasUrl(),
                        collapsedHeader: $collapsedHeader
                    )
                    ExternalLinkPill(
                        title: "Ladok",
                        image: "link",
                        url: URL(string: parentViewModel.ladokUrl),
                        collapsedHeader: $collapsedHeader
                    )
                }
                .padding(.top, collapsedHeader ? 0 : 10)
            }
        }
        .padding(.bottom, collapsedHeader ? 15 : 20)
    }
}

