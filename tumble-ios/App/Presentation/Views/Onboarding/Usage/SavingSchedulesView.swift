//
//  SavingSchedulesView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct SavingSchedulesView: View {
    var body: some View {
        ScrollView {
            UsageStepCardView(titleInstruction: "Search", bodyInstruction: "Search for a schedule from the search page", image: "magnifyingglass")
            
            UsageStepCardView(titleInstruction: "Open", bodyInstruction: "Open the schedule you want to view", image: "rectangle.and.hand.point.up.left.filled")
            
            UsageStepCardView(titleInstruction: "Bookmark", bodyInstruction: "Press the bookmark icon on the bottom left ", image: "bookmark")
            
            UsageStepCardView(titleInstruction: "Check it out", bodyInstruction: "View your schedule in your schedule view", image: "arrowshape.turn.up.backward")
        }
        .padding(.bottom, 30)
    }
}

struct SavingSchedulesView_Previews: PreviewProvider {
    static var previews: some View {
        SavingSchedulesView()
    }
}
