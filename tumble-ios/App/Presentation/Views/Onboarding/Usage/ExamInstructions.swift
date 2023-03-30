//
//  SigningUpExamsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct ExamInstructions: View {
    var body: some View {
        ScrollView (showsIndicators: false) {
            UsageCard(
                titleInstruction: NSLocalizedString("Account page", comment: ""),
                bodyInstruction: NSLocalizedString("Press the account page tab on the bottom", comment: ""),
                image: "person")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Log in", comment: ""),
                bodyInstruction: NSLocalizedString("Log in with your institution credentials", comment: ""),
                image: "arrow.up.and.person.rectangle.portrait")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Click", comment: ""),
                bodyInstruction: NSLocalizedString("Navigate to the event booking page by pressing 'See all'", comment: ""),
                image: "rectangle.and.hand.point.up.left")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Choose", comment: ""),
                bodyInstruction: NSLocalizedString("Select an available event to sign up for and press the register button", comment: ""),
                image: "signature")
            
            UsageCard(
                titleInstruction: NSLocalizedString("Done", comment: ""),
                bodyInstruction: NSLocalizedString("Now you've signed up for the specified exam, check your email for confirmation", comment: ""),
                image: "checkmark.seal")
                .padding(.bottom, 55)
        }
    }
}

struct SigningUpExamsView_Previews: PreviewProvider {
    static var previews: some View {
        ExamInstructions()
    }
}
