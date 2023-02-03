//
//  AccountPageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import Foundation

enum AccountPageViewStatus {
    case loading
    case signedIn
    case error
    case notSignedIn
}

extension AccountPageView {
    @MainActor final class AccountPageViewModel: ObservableObject {
        @Published var status: AccountPageViewStatus = .loading
    }
}
