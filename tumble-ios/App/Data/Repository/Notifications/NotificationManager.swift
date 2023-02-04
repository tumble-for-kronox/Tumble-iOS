//
//  NotificationManager.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation
import UserNotifications

class NotificationManager: NotificationManagerProtocol {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let authorizationOptions: UNAuthorizationOptions = [.alert, .sound, .badge]

    func scheduleNotification(_ notification: Notification, userOffset: Int) {
        AppLogger.shared.info("Trying to set notification")
        notificationsAreAllowed {   result in
            switch result {
            case .success:
                self.notificationCenter.add(self.request(for: notification, userOffset: userOffset))
                AppLogger.shared.info("Successfully set notification for event with id -> \(notification.id)")
            case .failure:
                AppLogger.shared.info("Could not set notification")
            }
        }
    }

    func cancelNotification(eventId: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [eventId])
    }
    
    func isNotificationScheduled(notificationId: String, completion: @escaping (Bool) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            let isScheduled = requests.contains { $0.identifier == notificationId }
            completion(isScheduled)
        }
    }
}


extension NotificationManager {
    
    fileprivate func request(for notification: Notification, userOffset: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.sound = .default
        content.badge = 1
        
        let components = dateComponentsAfterSubtractingUserOffset(dateComponents: notification.dateComponents, userOffset: userOffset)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        return UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger)
    }

    fileprivate func dateComponentsAfterSubtractingUserOffset(dateComponents: DateComponents, userOffset: Int) -> DateComponents {
        let calendarDateFromComponents = Calendar(identifier: .gregorian).date(from: dateComponents)
        let subtractUserOffset = Calendar.current.date(byAdding: .minute, value: -userOffset, to: calendarDateFromComponents!)
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: subtractUserOffset!)
    }
    
    fileprivate func notificationsAreAllowed(completion: ((Result<Bool, NotificationError>) -> Void)? = nil) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion?(.success(true))
            default:
                self.requestAuthorization { result in
                    switch result {
                    case .success:
                        completion?(.success(true))
                    case .failure(let error):
                        completion?(.failure(error))
                        AppLogger.shared.info("\(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    fileprivate func requestAuthorization(completion: ((Result<Bool, NotificationError>) -> Void)? = nil) {
        AppLogger.shared.info("Requesting authorization")
        notificationCenter.requestAuthorization(options: authorizationOptions) { success, error in
            if success {
                completion?(.success(true))
            } else {
                completion?(.failure(.internal(reason: "Notifications were not allowed by user")))
            }
        }
    }
    
}
