//
//  AccountPageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct AccountPageView: View {
    @ObservedObject var viewModel: AccountPageViewModel
    var body: some View {
        VStack (alignment: .center) {
            switch viewModel.status {
            case .loading:
                InfoLoadingView(title: "Attempting to sign in")
            case .signedIn:
                Text("User is signed in!")
            case .notSignedIn:
                Text("User is not signed in!")
            case .error:
                Text("Error occurred when signing in")
            }
        }
    }
}

