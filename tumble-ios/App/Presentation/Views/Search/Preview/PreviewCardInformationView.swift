//
//  PreviewCardInformationView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import SwiftUI

struct PreviewCardInformationView: View {
    let title: String
    let courseName: String
    let location: String
    var body: some View {
        VStack (alignment: .leading) {
            Text(title)
                .titleCard()
            VStack {
                Text(courseName)
                    .courseNameCard()
                Spacer()
            }
            HStack {
                Spacer()
                Text(location)
                    .locationCard()
                Image(systemName: "mappin.and.ellipse")
                    .font(.title3)
                    .foregroundColor(.onSurface)
                    .padding(.trailing, 5)
            }
            .padding(.trailing, 10)
            Spacer()
        }
    }
}

