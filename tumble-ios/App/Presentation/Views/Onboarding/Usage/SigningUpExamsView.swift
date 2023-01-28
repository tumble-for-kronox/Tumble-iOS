//
//  SigningUpExamsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct SigningUpExamsView: View {
    var body: some View {
        ScrollView {
            UsageStepCardView(titleInstruction: "Account page", bodyInstruction: "Press the account page tab on the bottom", image: "graduationcap")
            
            UsageStepCardView(titleInstruction: "Sign in", bodyInstruction: "Sign in with your institutions credentials", image: "arrow.up.and.person.rectangle.portrait")
            
            UsageStepCardView(titleInstruction: "Swipe", bodyInstruction: "Navigate to the exams tab view", image: "rectangle.and.hand.point.up.left")
            
            UsageStepCardView(titleInstruction: "Exams", bodyInstruction: "Select an available exam to sign up for and press the register button", image: "pencil.tip")
            
            UsageStepCardView(titleInstruction: "Done", bodyInstruction: "Now you've signed up for the specified exam, check your email for confirmation", image: "checkmark.seal")
        }
        .padding(.bottom, 30)
    }
}

struct SigningUpExamsView_Previews: PreviewProvider {
    static var previews: some View {
        SigningUpExamsView()
    }
}
