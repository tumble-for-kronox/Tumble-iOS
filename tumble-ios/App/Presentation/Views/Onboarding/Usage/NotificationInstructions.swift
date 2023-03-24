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
            UsageCard(titleInstruction: "Bookmarks page", bodyInstruction: "Press the bookmarks tab in the tab bar", image: "bookmark")
 
            UsageCard(titleInstruction: "Click", bodyInstruction: "Click an event card in your schedule", image: "rectangle.and.hand.point.up.left")
            
            UsageCard(titleInstruction: "Select", bodyInstruction: "Press the 'Event' or 'Course' notification setting in the sheet that appears", image: "bell.badge")
            
            UsageCard(titleInstruction: "Done", bodyInstruction: "A notification will be set for the specified event or course", image: "checkmark.seal")
            
        }
    }
}

struct SettingNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationInstructions()
    }
}
