//
//  SigningUpExamsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct ExamInstructions: View {
    var body: some View {
        ScrollView {
            UsageCard(titleInstruction: "Account page", bodyInstruction: "Press the account page tab on the bottom", image: "graduationcap")
            
            UsageCard(titleInstruction: "Sign in", bodyInstruction: "Sign in with your institutions credentials", image: "arrow.up.and.person.rectangle.portrait")
            
            UsageCard(titleInstruction: "Swipe", bodyInstruction: "Navigate to the exams tab view", image: "rectangle.and.hand.point.up.left")
            
            UsageCard(titleInstruction: "Exams", bodyInstruction: "Select an available exam to sign up for and press the register button", image: "pencil.tip")
            
            UsageCard(titleInstruction: "Done", bodyInstruction: "Now you've signed up for the specified exam, check your email for confirmation", image: "checkmark.seal")
                .padding(.bottom, 55)
        }
    }
}

struct SigningUpExamsView_Previews: PreviewProvider {
    static var previews: some View {
        ExamInstructions()
    }
}
