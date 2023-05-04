//
//  AccountViewModelExtension.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension AccountViewModel {
    func scheduleBookingNotifications(for bookings: Response.KronoxUserBookings) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            // Remove all old notifications in case booking has been changed externally or internally
            self.notificationManager.cancelNotifications(with: "Booking")
            for booking in bookings {
                if let notification = self.notificationManager.createNotificationFromBooking(booking: booking) {
                    self.notificationManager.scheduleNotification(
                        for: notification,
                        type: .booking,
                        userOffset: self.preferenceService.getNotificationOffset(),
                        completion: { result in
                            switch result {
                            case .success(let success):
                                AppLogger.shared.info("Scheduled \(success) notification")
                            case .failure(let failure):
                                AppLogger.shared.debug("Failed : \(failure)")
                            }
                        }
                    )
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
        userController.authenticateAndExecute(
            authSchoolId: authSchoolId,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.registerAllEvents(schoolId: String(schoolId))
                    _ = kronoxManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                                          then: { (result: Result<Response.KronoxEventRegistration?, Response.ErrorMessage>) in
                                              DispatchQueue.main.async {
                                                  switch result {
                                                  case .success(let eventRegistrations):
                                                      if let eventRegistrations = eventRegistrations {
                                                          AppLogger.shared.debug("Successful registrations: \(String(describing: eventRegistrations.successfulRegistrations?.count))")
                                                          AppLogger.shared.debug("Failed registrations: \(String(describing: eventRegistrations.failedRegistrations?.count))")
                                                          completion(.success(()))
                                                      }
                                                  case .failure(let failure):
                                                      AppLogger.shared.critical("Failed to automatically sign up for exams: \(failure)")
                                                      completion(.failure(.generic(reason: "\(failure)")))
                                                  }
                                              }
                                          })
                case .failure(let failure):
                    AppLogger.shared.critical("Could not log in to register for available events")
                    completion(.failure(.generic(reason: "\(failure)")))
                case .demo:
                    completion(.success(()))
                }
            }
        )
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
