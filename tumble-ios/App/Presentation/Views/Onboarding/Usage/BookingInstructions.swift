//
//  SigningUpExamsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct BookingInstructions: View {
    var body: some View {
        ScrollView (showsIndicators: false) {
            UsageCard(
                titleInstruction: NSLocalizedString("Account page", comment: ""),
                bodyInstruction: NSLocalizedString("Press the account page tab on the bottom", comment: ""),
                image: "person")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Login", comment: ""),
                bodyInstruction: NSLocalizedString("Log in with your institution credentials", comment: ""),
                image: "arrow.up.and.person.rectangle.portrait")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Click", comment: ""),
                bodyInstruction: NSLocalizedString("Navigate to the resource booking page by pressing 'Book more'", comment: ""),
                image: "rectangle.and.hand.point.up.left")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Date", comment: ""),
                bodyInstruction: NSLocalizedString("Choose a time to search for available dates and select an opening", comment: ""),
                image: "calendar")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Building", comment: ""),
                bodyInstruction: NSLocalizedString("Select a building on campus to book a room in, then select a room for a specific timeslot", comment: ""),
                image: "building.2")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Confirm", comment: ""),
                bodyInstruction: NSLocalizedString("Now confirm your selected booking by pressing the confirm button", comment: ""),
                image: "checkmark.seal")
                .padding(.bottom, 55)
        }
    }
}

struct BookingRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        BookingInstructions()
    }
}
