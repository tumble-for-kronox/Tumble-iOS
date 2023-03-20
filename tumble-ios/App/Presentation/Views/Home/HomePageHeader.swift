//
//  HomePageHeader.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import SwiftUI

struct HomePageHeader: View {
    
    @ObservedObject var parentViewModel: HomePageViewModel
    @Binding var domain: String?
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 0) {
                Text(getCurrentDate())
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                HStack (spacing: 10) {
                    ExternalLinkPill(title: domain?.uppercased() ?? "", image: "link", url: parentViewModel.makeUniversityUrl())
                    ExternalLinkPill(title: "Canvas", image: "link", url: parentViewModel.makeCanvasUrl())
                    ExternalLinkPill(title: "Ladok", image: "link", url: URL(string: ladokUrl))
                }
                .padding(.top, 10)

            }
            Spacer()
        }
        .padding(.bottom, 20)
    }
}

