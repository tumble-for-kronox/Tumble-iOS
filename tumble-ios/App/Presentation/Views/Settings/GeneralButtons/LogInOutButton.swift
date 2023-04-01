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
    
    @State private var shouldReloadView = false
    
    var body: some View {
        Button(action: {
            if parentViewModel.userController.authStatus == .authorized {
                parentViewModel.logOut()
            } else {
                AppController.shared.selectedAppTab = .account
                dismiss()
            }
        }, label: {
            HStack {
                Spacer()
                if parentViewModel.userController.authStatus == .authorized {
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
        .id(shouldReloadView)
        .onChange(of: parentViewModel.userController.authStatus) { _ in
            shouldReloadView.toggle()
        }
    }
}
