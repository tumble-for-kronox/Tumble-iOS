//
//  AccountViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension AccountViewModel {
    
    func scheduleBookingNotifications(for bookings: Response.KronoxUserBookings) -> Void {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            for booking in bookings {
                if let dateComponents = booking.dateComponentsConfirmation {
                    let notification = BookingNotification(
                        id: booking.id,
                        dateComponents: dateComponents
                    )
                    self.notificationManager.scheduleNotification(
                        for: notification,
                        type: .booking,
                        userOffset: self.preferenceService.getNotificationOffset(),
                        completion: { result in
                            switch result {
                            case .success(let success):
                                AppLogger.shared.debug("Scheduled \(success) notification")
                            case .failure(let failure):
                                AppLogger.shared.debug("Failed : \(failure)")
                            }
                        })
                } else {
                    AppLogger.shared.critical("Failed to retrieve date components for booking")
                }
            }
        }
    }
    
    func registerAutoSignup(
        tries: Int = 0,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        AppLogger.shared.debug("Automatically signing up for exams")
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.registerAllEvents(schoolId: String(schoolId))
                    let _ = networkManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { (result: Result<Response.KronoxEventRegistration?, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let eventRegistrations):
                                if let eventRegistrations = eventRegistrations {
                                    AppLogger.shared.debug("Successful registrations: \(String(describing: eventRegistrations.successfulRegistrations?.count))")
                                    AppLogger.shared.debug("Failed registrations: \(String(describing: eventRegistrations.failedRegistrations?.count))")
                                    completion(.success(()))
                                }
                            case .failure(let error):
                                AppLogger.shared.critical("Failed to automatically sign up for exams: \(error)")
                                completion(.failure(.generic(reason: "\(error)")))
                            }
                        }
                    })
                case .failure(let error):
                    AppLogger.shared.critical("Could not log in to register for available events")
                    completion(.failure(.generic(reason: "\(error)")))
                }
            })
    }
    
    /// Wrapper function that is meant to be used on functions
    /// that require authentication to be active before processing
    func authenticateAndExecute(
        tries: Int = 0,
        school: School?,
        refreshToken: Token?,
        execute: @escaping (Result<(Int, String), Error>) -> Void
    ) {
        
        guard let school = school,
              let refreshToken = refreshToken,
              !refreshToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS && userController.authStatus == .authorized {
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin { [unowned self] in
                    self.authenticateAndExecute(
                        tries: tries + 1,
                        school: school,
                        refreshToken: refreshToken,
                        execute: execute
                    )
                }
            } else {
                execute(.failure(.internal(reason: "Could not authenticate user")))
            }
            return
        }
        execute(.success((school.id, refreshToken.value)))
    }
    
    func cancelDataTaskIfTabChanged(dataTask: URLSessionDataTask?) {
        let currentSelectedTab = AppController.shared.selectedAppTab
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1)) {
            if AppController.shared.selectedAppTab != currentSelectedTab {
                DispatchQueue.main.async {
                    // selected app tab has changed, cancel the dataTask
                    AppLogger.shared.debug("Cancelling task due to tab change")
                    dataTask?.cancel()
                }
            }
        }
    }


}
