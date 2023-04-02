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
                HStack (alignment: .center, spacing: 10) {
                    ExternalLinkPill(
                        title: domain?.uppercased() ?? "",
                        image: "link",
                        url: parentViewModel.makeUniversityUrl(),
                        color: .green,
                        collapsedHeader: $collapsedHeader)
                    ExternalLinkPill(
                        title: "Canvas",
                        image: "link",
                        url: parentViewModel.makeCanvasUrl(),
                        color: .pink,
                        collapsedHeader: $collapsedHeader
                    )
                    ExternalLinkPill(
                        title: "Ladok",
                        image: "link",
                        url: URL(string: parentViewModel.ladokUrl),
                        color: .blue,
                        collapsedHeader: $collapsedHeader
                    )
                }
                .padding(.top, collapsedHeader ? 0 : 10)
            }
        }
        .padding(.bottom, collapsedHeader ? 15 : 20)
    }
}

