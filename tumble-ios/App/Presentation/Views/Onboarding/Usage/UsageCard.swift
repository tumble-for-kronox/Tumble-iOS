//
//  UsageStepCardView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct UsageCard: View {
    let titleInstruction: String
    let bodyInstruction: String
    let image: String
    var body: some View {
        HStack {
            Image(systemName: image)
                .font(.system(size: 40))
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 60)
                .padding(10)
            VStack (alignment: .leading, spacing: 0) {
                Text(titleInstruction)
                    .titleInstructions()
                Text(bodyInstruction)
                    .titleBody()
            }
            .frame(minHeight: 70, alignment: .top)
            .padding(.trailing, 10)
            .padding([.top, .bottom], 10)
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, alignment: .center)
        .background(Color("SurfaceColor"))
        .cornerRadius(10)
        .padding([.leading, .trailing], 20)
        .padding([.bottom, .top], 10)
        
    }
}

struct UsageStepCardView_Previews: PreviewProvider {
    static var previews: some View {
        UsageCard(titleInstruction: "Open", bodyInstruction: "Open the schedule you want to view", image: "rectangle.and.hand.point.up.left.filled")
    }
}
