//
//  CustomizeCourseColorsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct CustomizeCourseColorsView: View {
    var body: some View {
        ScrollView {
            UsageStepCardView(titleInstruction: "Schedule page", bodyInstruction: "Press the schedule page tab on the bottom", image: "list.bullet.clipboard")
 
            UsageStepCardView(titleInstruction: "Hold", bodyInstruction: "Hold your finger on an event card in your schedule", image: "dot.circle.and.hand.point.up.left.fill")
            
            UsageStepCardView(titleInstruction: "Press", bodyInstruction: "Press the \"Change course color\" option on the modal that appears", image: "rectangle.and.hand.point.up.left")
            
            UsageStepCardView(titleInstruction: "Modify", bodyInstruction: "Choose any color from the color palette and apply it", image: "paintpalette")
            
            UsageStepCardView(titleInstruction: "Done", bodyInstruction: "The specific course under the event will have a new color", image: "checkmark.seal")
                .padding(.bottom, 55)
        }
        .padding(.bottom, 30)
    }
}

struct CustomizeCourseColorsView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeCourseColorsView()
    }
}
