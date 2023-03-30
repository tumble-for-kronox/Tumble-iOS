//
//  SavingSchedulesView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct BookmarkInstructions: View {
    var body: some View {
        ScrollView (showsIndicators: false) {
            UsageCard(
                titleInstruction: NSLocalizedString("Search", comment: ""),
                bodyInstruction: NSLocalizedString("Search for a schedule from the search page", comment: ""),
                image: "magnifyingglass")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Open", comment: ""),
                bodyInstruction: NSLocalizedString("Open the schedule you want to view", comment: ""),
                image: "rectangle.and.hand.point.up.left.filled")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Bookmark", comment: ""),
                bodyInstruction: NSLocalizedString("Press the 'bookmark' button on the bottom left ", comment: ""),
                image: "bookmark")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Check it out", comment: ""),
                bodyInstruction: NSLocalizedString("View your schedule in your preferred schedule view", comment: ""),
                image: "arrowshape.turn.up.backward")
        }
    }
}

struct SavingSchedulesView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkInstructions()
    }
}
