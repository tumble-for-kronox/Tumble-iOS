//
//  FeatureCardView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct FeatureCardView: View {
    let title: String
    let image: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("SurfaceColor"))
            HStack {
                Text(title)
                    .featureText()
                Spacer()
                Image(systemName: image)
                    .featureIcon()
                    
            }
            .padding([.leading, .trailing], 20)
        }
        .frame(height: 50)
        .padding([.leading, .trailing], 20)
        .padding([.top, .bottom], 10)
    }
}

struct FeatureCardView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCardView(title: "Save schedules", image: "list.bullet.clipboard")
    }
}
