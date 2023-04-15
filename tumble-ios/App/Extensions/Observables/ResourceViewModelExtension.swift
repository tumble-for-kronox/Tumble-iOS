//
//  ResourceViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension ResourceViewModel {
    
    /// Wrapper function that is meant to be used on functions
    /// that require authentication to be active before processing
    func authenticateAndExecute(
        tries: Int = 0,
        schoolId: Int,
        refreshToken: Token?,
        execute: @escaping (Result<(Int, String), Error>) -> Void
    ) {
        guard let refreshToken = refreshToken,
              !refreshToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS && userController.authStatus == .authorized {
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin { [unowned self] in
                    self.authenticateAndExecute(
                        tries: tries + 1,
                        schoolId: schoolId,
                        refreshToken: refreshToken,
                        execute: execute
                    )
                }
            } else {
                execute(.failure(.internal(reason: "Could not authenticate user")))
            }
            return
        }
        execute(.success((schoolId, refreshToken.value)))
    }
    
    func cancelDataTaskIfDateChanged(dataTask: URLSessionDataTask?, date: Date) {
        let currentSelectedDate = date
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1)) {
            if self.selectedPickerDate != currentSelectedDate {
                DispatchQueue.main.async {
                    // Selected date has changed, cancel the dataTask
                    AppLogger.shared.critical("Cancelling task due to date change")
                    dataTask?.cancel()
                }
            }
        }
    }
    
}
