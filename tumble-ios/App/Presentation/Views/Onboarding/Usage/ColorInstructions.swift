//
//  CustomizeCourseColorsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct ColorInstructions: View {
    var body: some View {
        ScrollView (showsIndicators: false) {
            UsageCard(titleInstruction: "Bookmarks page", bodyInstruction: "Press the bookmarks tab in the tab bar", image: "bookmark")
 
            UsageCard(titleInstruction: "Click", bodyInstruction: "Click an event card in your schedule", image: "rectangle.and.hand.point.up.left")
            
            UsageCard(titleInstruction: "Select", bodyInstruction: "Press the 'Color' option in the sheet that appears", image: "paintpalette")
            
            UsageCard(titleInstruction: "Apply", bodyInstruction: "Choose any color from the color palette and apply it", image: "paintbrush")
            
            UsageCard(titleInstruction: "Done", bodyInstruction: "The specific course under the event will have a new color", image: "checkmark.seal")
                .padding(.bottom, 55)
        }
    }
}

struct CustomizeCourseColorsView_Previews: PreviewProvider {
    static var previews: some View {
        ColorInstructions()
    }
}
