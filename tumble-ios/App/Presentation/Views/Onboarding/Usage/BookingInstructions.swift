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
            UsageCard(titleInstruction: "Account page", bodyInstruction: "Press the account page tab on the bottom", image: "person")
            
            UsageCard(titleInstruction: "Sign in", bodyInstruction: "Sign in with your institution credentials", image: "arrow.up.and.person.rectangle.portrait")
            
            UsageCard(titleInstruction: "Click", bodyInstruction: "Navigate to the resource booking page by pressing 'Book more'", image: "rectangle.and.hand.point.up.left")
            
            UsageCard(titleInstruction: "Date", bodyInstruction: "Choose a time to search for available dates and select an opening", image: "calendar")
            
            UsageCard(titleInstruction: "Building", bodyInstruction: "Select a building on campus to book a room in, then select a room for a specific timeslot", image: "building.2")
            
            UsageCard(titleInstruction: "Confirm", bodyInstruction: "Now confirm your selected booking by pressing the confirm button", image: "checkmark.seal")
                .padding(.bottom, 55)
        }
    }
}

struct BookingRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        BookingInstructions()
    }
}
