//
//  LogInOutButton.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-31.
//

import SwiftUI

struct LogInOutButton: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var parentViewModel: SettingsViewModel
    
    @State private var isConfirming: Bool = false
    var settingsDetails: SettingsDetails = .init(
        titleKey: NSLocalizedString("Are you sure you want to log out of your account?", comment: ""),
        name: NSLocalizedString("Log out of your account", comment: ""),
        details: NSLocalizedString("This action will log you out of your KronoX account", comment: "")
    )
    
    var body: some View {
        Button(action: {
            switch parentViewModel.authStatus {
            case .unAuthorized:
                AppController.shared.selectedAppTab = .account
                dismiss()
            case .authorized:
                isConfirming = true
            case .loading:
                break
            }
        }, label: {
            HStack {
                Spacer()
                switch parentViewModel.authStatus {
                case .unAuthorized:
                    Text(NSLocalizedString("Log in", comment: ""))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                case .authorized:
                    Text(NSLocalizedString("Log out", comment: ""))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                case .loading:
                    CustomProgressIndicator()
                }
                Spacer()
            }
            .padding(5)
        })
        .confirmationDialog(
            NSLocalizedString("Are you sure you want to log out of your account?", comment: ""),
            isPresented: $isConfirming, presenting: settingsDetails
        ) { _ in
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
