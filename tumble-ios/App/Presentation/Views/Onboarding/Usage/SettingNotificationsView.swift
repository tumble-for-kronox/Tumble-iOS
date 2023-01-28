//
//  SettingNotificationsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct SettingNotificationsView: View {
    var body: some View {
        ScrollView {
            UsageStepCardView(titleInstruction: "Schedule page", bodyInstruction: "Press the schedule page tab on the bottom", image: "list.bullet.clipboard")
 
            UsageStepCardView(titleInstruction: "Hold", bodyInstruction: "Hold your finger on an event card in your schedule", image: "dot.circle.and.hand.point.up.left.fill")
            
            UsageStepCardView(titleInstruction: "Press", bodyInstruction: "Press the \"Set notification\" or \"Set notification for course\" option on the modal that appears", image: "rectangle.and.hand.point.up.left")
            
            UsageStepCardView(titleInstruction: "Done", bodyInstruction: "A notification will be set for the specified event or course", image: "checkmark.seal")
            
        }
        .padding(.bottom, 30)
    }
}

struct SettingNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingNotificationsView()
    }
}
