//
//  SavingSchedulesView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct BookmarkInstructions: View {
    var body: some View {
        ScrollView {
            UsageCard(titleInstruction: "Search", bodyInstruction: "Search for a schedule from the search page", image: "magnifyingglass")
            
            UsageCard(titleInstruction: "Open", bodyInstruction: "Open the schedule you want to view", image: "rectangle.and.hand.point.up.left.filled")
            
            UsageCard(titleInstruction: "Bookmark", bodyInstruction: "Press the bookmark icon on the bottom left ", image: "bookmark")
            
            UsageCard(titleInstruction: "Check it out", bodyInstruction: "View your schedule in your schedule view", image: "arrowshape.turn.up.backward")
        }
    }
}

struct SavingSchedulesView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkInstructions()
    }
}
