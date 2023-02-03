//
//  SigningUpExamsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct BookingRoomsView: View {
    var body: some View {
        ScrollView {
            UsageStepCardView(titleInstruction: "Account page", bodyInstruction: "Press the account page tab on the bottom", image: "graduationcap")
            
            UsageStepCardView(titleInstruction: "Sign in", bodyInstruction: "Sign in with your institutions credentials", image: "arrow.up.and.person.rectangle.portrait")
            
            UsageStepCardView(titleInstruction: "Swipe", bodyInstruction: "Navigate to the room booking tab view", image: "rectangle.and.hand.point.up.left")
            
            UsageStepCardView(titleInstruction: "Building", bodyInstruction: "Select a building on campus to book a room in, then select a room", image: "building.2")
            
            UsageStepCardView(titleInstruction: "Date", bodyInstruction: "Choose a time to search for available dates and select an opening", image: "calendar")
            
            UsageStepCardView(titleInstruction: "Confirm", bodyInstruction: "Now confirm your selected booking by pressing the confirm button", image: "checkmark.seal")
                .padding(.bottom, 55)
        }
    }
}

struct BookingRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        BookingRoomsView()
    }
}
