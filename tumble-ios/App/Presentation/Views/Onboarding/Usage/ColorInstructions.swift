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
                bodyInstruction: NSLocalizedString("Press the 'Color' option in the sheet that appears", comment: ""),
                image: "paintpalette")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Apply", comment: ""),
                bodyInstruction: NSLocalizedString("Choose any color from the color palette and apply it", comment: ""),
                image: "paintbrush")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Done", comment: ""),
                bodyInstruction: NSLocalizedString("The specific course under the event will have a new color", comment: ""),
                image: "checkmark.seal")
                .padding(.bottom, 55)
        }
    }
}

struct CustomizeCourseColorsView_Previews: PreviewProvider {
    static var previews: some View {
        ColorInstructions()
    }
}
