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
            UsageCard(titleInstruction: "Schedule page", bodyInstruction: "Press the schedule page tab on the bottom", image: "list.bullet.clipboard")
 
            UsageCard(titleInstruction: "Hold", bodyInstruction: "Hold your finger on an event card in your schedule", image: "dot.circle.and.hand.point.up.left.fill")
            
            UsageCard(titleInstruction: "Press", bodyInstruction: "Press the \"Set notification\" or \"Set notification for course\" option on the modal that appears", image: "rectangle.and.hand.point.up.left")
            
            UsageCard(titleInstruction: "Done", bodyInstruction: "A notification will be set for the specified event or course", image: "checkmark.seal")
            
        }
    }
}

struct SettingNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationInstructions()
    }
}
