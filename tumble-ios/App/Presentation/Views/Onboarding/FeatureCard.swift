//
//  FeatureCardView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct FeatureCard: View {
    let title: String
    let image: String
    var body: some View {
        HStack (alignment: .center) {
            Text(title)
                .featureText()
            Spacer()
            Image(systemName: image)
                .featureIcon()
        }
        .padding(.horizontal, 15)
        .frame(height: 50)
        .background(Color.surface)
        .cornerRadius(15)
        .padding(.horizontal, 15)
        .padding([.top, .bottom], 10)
    }
}

struct FeatureCardView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCard(title: "Save schedules", image: "bookmarks")
    }
}
