//
//  LogInOutButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-31.
//

import SwiftUI

struct LogInOutButton: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var parentViewModel: SettingsViewModel
    
    @State private var isConfirming: Bool = false
    var settingsDetails: SettingsDetails = SettingsDetails(
        titleKey: NSLocalizedString("Are you sure you want to log out of your account?", comment: ""),
        name: "Log out of your account",
        details: "This action will log you out of your KronoX account")
    
    var isAuthorized: Bool {
        return parentViewModel.userController.authStatus == .authorized
    }
    
    var body: some View {
        Button(action: {
            if isAuthorized {
                isConfirming = true
            } else {
                AppController.shared.selectedAppTab = .account
                dismiss()
            }
        }, label: {
            HStack {
                Spacer()
                if isAuthorized {
                    Text(NSLocalizedString("Log out", comment: ""))
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                } else {
                    Text(NSLocalizedString("Log in", comment: ""))
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                }
                Spacer()
            }
        })
        .confirmationDialog(
            NSLocalizedString("Are you sure you want to log out of your account?", comment: ""),
            isPresented: $isConfirming, presenting: settingsDetails
        ) { detail in
            Button {
                parentViewModel.logOut()
            } label: {
                Text(NSLocalizedString(settingsDetails.name, comment: ""))
                    .foregroundColor(.red)
            }
            Button("Cancel", role: .cancel) {
                isConfirming = false
            }
        }
    }
}
