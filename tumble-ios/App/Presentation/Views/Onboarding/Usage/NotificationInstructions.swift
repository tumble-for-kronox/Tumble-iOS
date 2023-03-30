//
//  SettingNotificationsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct NotificationInstructions: View {
    var body: some View {
        ScrollView (showsIndicators: false) {
            UsageCard(
                titleInstruction: NSLocalizedString("Bookmarks page", comment: ""),
                bodyInstruction: NSLocalizedString("Press the bookmarks tab in the tab bar", comment: ""),
                image: "bookmark")
 
            UsageCard(
                titleInstruction: NSLocalizedString("Click", comment: ""),
                bodyInstruction: NSLocalizedString("Click an event card in your schedule", comment: ""),
                image: "rectangle.and.hand.point.up.left")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Select", comment: ""),
                bodyInstruction: NSLocalizedString("Press the 'Event' or 'Course' notification setting in the sheet that appears", comment: ""),
                image: "bell.badge")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Done", comment: ""),
                bodyInstruction: NSLocalizedString("A notification will be set for the specified event or course", comment: ""),
                image: "checkmark.seal")
            
        }
    }
}

struct SettingNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationInstructions()
    }
}
