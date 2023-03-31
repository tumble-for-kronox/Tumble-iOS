//
//  LogInOutButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-31.
//

import SwiftUI

struct LogInOutButton: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var parentViewModel: SettingsViewModel
    @State private var loggedIn: Bool
    
    init(parentViewModel: SettingsViewModel) {
        self.parentViewModel = parentViewModel
        self._loggedIn = State(initialValue: parentViewModel.userAuthenticatedAndSignedIn())
    }
    
    var body: some View {
        Button(action: {
            if loggedIn {
                parentViewModel.logOut()
                self.loggedIn = false
            } else {
                AppController.shared.selectedAppTab = .account
                dismiss()
            }
        }, label: {
            HStack {
                Spacer()
                if loggedIn {
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
    }
}

