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
            for booking in bookings {
                if let notification = self.notificationManager.createNotificationFromBooking(booking: booking) {
                    self.notificationManager.scheduleNotification(
                        for: notification,
                        type: .booking,
                        userOffset: self.preferenceService.getNotificationOffset(),
                        completion: { result in
                            switch result {
                            case .success(let success):
                                AppLogger.shared.debug("Scheduled \(success) notification with id: \(notification.id)")
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
    
    func registerAutoSignup() async {
        AppLogger.shared.debug("Attempting to automatically sign up for exams")
        do {
            let request = Endpoint.registerAllEvents(schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                // TODO: Handle error
                return
            }
            let _: Response.KronoxEventRegistration?
                = try await kronoxManager.put(request, refreshToken: refreshToken.value, body: Request.Empty())
        } catch (let error) {
            AppLogger.shared.critical("Failed to sign up for exams: \(error)")
        }
    }
    
}
