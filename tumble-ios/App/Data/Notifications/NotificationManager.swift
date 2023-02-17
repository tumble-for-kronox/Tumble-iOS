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

    func scheduleNotification(for notification: Notification, userOffset: Int, completion: @escaping (Result<Int, NotificationError>) -> Void) {
        notificationsAreAllowed { result in
            switch result {
            case .success:
                //#if DEBUG
                //let calendar = Calendar(identifier: .gregorian)
                //let date = calendar.date(byAdding: .second, value: 10, to: Date.now)
                //let dateComponents: DateComponents = calendar.dateComponents([.year, .month, .weekday, .hour, .minute, .second], from: date!)
                //let testNotification = Notification(id: notification.id, color: notification.color, dateComponents: dateComponents, categoryIdentifier: notification.categoryIdentifier, content: notification.content)
                //self.notificationCenter.add(self.request(for: testNotification, userOffset: 0))
                //AppLogger.shared.info("Successfully set DEBUG notification for event with id -> \(notification.id) at time \(dateComponents)")
                //completion(.success(1))
                //#endif
                self.notificationCenter.add(self.request(for: notification, userOffset: userOffset))
                AppLogger.shared.info("Successfully set notification for event with id -> \(notification.id)")
                completion(.success(1))
            case .failure(let error):
                AppLogger.shared.info("Could not set notification")
                completion(.failure(error))
            }
        }
    }

    func cancelNotification(for eventId: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [eventId])
        AppLogger.shared.info("Cancelled notifications with eventId -> \(eventId)")
    }
    
    func isNotificationScheduled(eventId: String, completion: @escaping (Bool) -> Void) -> Void {
        notificationCenter.getPendingNotificationRequests { requests in
            let isScheduled = requests.contains { $0.identifier == eventId }
            completion(isScheduled)
        }
    }
    
    func isNotificationScheduled(categoryIdentifier: String, completion: @escaping (Bool) -> Void) -> Void {
        notificationCenter.getPendingNotificationRequests { (requests) in
            let requestsWithMatchingCategory = requests.filter { $0.content.categoryIdentifier == categoryIdentifier }
            completion(!requestsWithMatchingCategory.isEmpty)
        }
    }

    
    func cancelNotifications(with categoryIdentifier: String) {
        notificationCenter.getPendingNotificationRequests { [weak self] (requests) in
            guard let self = self else { return }
            let requestsWithMatchingCategory = requests.filter { $0.content.categoryIdentifier == categoryIdentifier }
            let identifiers = requestsWithMatchingCategory.map { $0.identifier }
            AppLogger.shared.info("Cancelling notifications with categoryIdentifier -> \(categoryIdentifier)")
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func cancelNotifications() -> Void {
        notificationCenter.removeAllPendingNotificationRequests()
        AppLogger.shared.info("Cancelled all notifications for this school")
    }
}


extension NotificationManager {
    
    fileprivate func request(for notification: Notification, userOffset: Int) -> UNNotificationRequest {
        AppLogger.shared.info("Making notification request for -> \(notification.id)")
        let content = UNMutableNotificationContent()
        content.title = (notification.content?.toEvent()?.course.englishName)!
        content.subtitle = (notification.content?.toEvent()?.title)!
        // Optional course id
        content.categoryIdentifier = notification.categoryIdentifier ?? ""
        content.sound = .default
        content.badge = 1
        content.userInfo[NotificationContentKey.event.rawValue] = notification.content
        content.userInfo[NotificationContentKey.color.rawValue] = notification.color
        
        let components = dateComponentsAfterSubtractingUserOffset(dateComponents: notification.dateComponents, userOffset: userOffset)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        //#if DEBUG
        //trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateComponents, repeats: false)
        //#endif
        
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
                        AppLogger.shared.info("\(error)")
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
