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

    func scheduleNotification<Notification : LocalNotification>(
        for notification: Notification,
        type: NotificationType,
        userOffset: Int,
        completion: @escaping (Result<Int, NotificationError>) -> Void) {
        notificationsAreAllowed { result in
            switch result {
            case .success:
                switch type {
                case .event:
                    if let eventNotification = notification as? EventNotification {
                        self.notificationCenter.add(self.requestEventNotification(for: eventNotification, userOffset: userOffset))
                    }
                case .booking:
                    if let bookingNotification = notification as? BookingNotification {
                        self.notificationCenter.add(self.requestBookingNotification(for: bookingNotification))
                    }
                }
                
                AppLogger.shared.debug("Successfully set notification with id -> \(notification.id)")
                completion(.success(1))
            case .failure(let failure):
                AppLogger.shared.critical("Could not set notification. Not allowed")
                completion(.failure(failure))
            }
        }
    }


    func cancelNotification(for id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        AppLogger.shared.debug("Cancelled notifications with id -> \(id)")
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
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.notificationCenter.getPendingNotificationRequests {  (requests) in
                let requestsWithMatchingCategory = requests.filter { $0.content.categoryIdentifier == categoryIdentifier }
                let identifiers = requestsWithMatchingCategory.map { $0.identifier }
                AppLogger.shared.debug("Cancelling notifications with categoryIdentifier -> \(categoryIdentifier)")
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
            }
        }
    }
    
    func cancelNotifications() -> Void {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            self.notificationCenter.removeAllPendingNotificationRequests()
            AppLogger.shared.debug("Cancelled all notifications for this school")
        }
    }
    
    func createNotificationFromEvent(event: Event) -> EventNotification? {
        guard let dateComponents = event.dateComponents else { return nil }
        if let course = event.course {
            let notification = EventNotification(
                id: event.eventId,
                color: course.color,
                dateComponents: dateComponents,
                categoryIdentifier: course.courseId, content: event.toDictionary()
            )
            return notification
        }
        return nil
    }
    
    func createNotificationFromBooking(booking: Response.KronoxUserBookingElement) -> BookingNotification? {
        guard let dateComponents = booking.dateComponentsConfirmation else { return nil }
        let notification = BookingNotification(
            id: booking.resourceID,
            dateComponents: dateComponents
        )
        return notification
    }
    
    func notificationsAreAllowed(completion: ((Result<Bool, NotificationError>) -> Void)? = nil) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion?(.success(true))
            case .denied:
                completion?(.failure(.internal(reason: "Notifications denied")))
            default:
                completion?(.failure(.internal(reason: "Notifications not allowed")))
            }
        }
    }
    
    func rescheduleEventNotifications(previousOffset: Int, userOffset: Int) {
        notificationCenter.getPendingNotificationRequests { [unowned self] requests in
            let eventRequests = requests.filter { $0.content.userInfo[NotificationContentKey.event.rawValue] != nil }
            AppLogger.shared.debug("Found \(eventRequests.count) notifications that need rescheduling")
            let modifiedRequests = eventRequests.map { request -> UNNotificationRequest in
                let trigger = request.trigger as! UNCalendarNotificationTrigger
                let newTrigger = UNCalendarNotificationTrigger(
                    dateMatching: self.dateComponentsAfterSubtractingUserOffset(
                        date: dateAfterAddingUserOffset(date: trigger.nextTriggerDate()!, userOffset: previousOffset),
                        userOffset: userOffset),
                    repeats: false)
                let modifiedRequest = UNNotificationRequest(identifier: request.identifier, content: request.content, trigger: newTrigger)
                return modifiedRequest
            }
            AppLogger.shared.debug("Removing \(eventRequests.map { $0.identifier }.count) notifications")
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: eventRequests.map { $0.identifier })
            for request in modifiedRequests {
                self.notificationCenter.add(request)
            }
            AppLogger.shared.debug("Rescheduled \(modifiedRequests.count) notifications")
        }
    }
}


extension NotificationManager {
    
    fileprivate func requestEventNotification(
        for notification: EventNotification,
        userOffset: Int) -> UNNotificationRequest {
            AppLogger.shared.debug("Making notification request for -> \(notification.id)")
            let content = UNMutableNotificationContent()
            content.title = (notification.content?.toEvent()?.course?.englishName ?? "")!
            content.subtitle = (notification.content?.toEvent()?.title)!
            // Optional course id
            content.categoryIdentifier = notification.categoryIdentifier ?? ""
            content.sound = .default
            content.badge = 1
            content.userInfo[NotificationContentKey.event.rawValue] = notification.content
            content.userInfo[NotificationContentKey.color.rawValue] = notification.color
            
            let components = dateComponentsAfterSubtractingUserOffset(
                dateComponents: notification.dateComponents,
                userOffset: userOffset
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            return UNNotificationRequest(
                identifier: notification.id,
                content: content,
                trigger: trigger
            )
    }
    
    fileprivate func requestBookingNotification(
        for notification: BookingNotification) -> UNNotificationRequest {
            let content = UNMutableNotificationContent()
            content.title = "Booking confirmation"
            content.subtitle = "A booking needs to be confirmed"
            content.sound = .default
            content.badge = 1
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateComponents, repeats: false)
            AppLogger.shared.debug("Created trigger with date components: \(notification.dateComponents)")
            return UNNotificationRequest(
                identifier: notification.id,
                content: content,
                trigger: trigger
            )
        }

    fileprivate func dateComponentsAfterSubtractingUserOffset(dateComponents: DateComponents, userOffset: Int) -> DateComponents {
        let calendarDateFromComponents = Calendar(identifier: .gregorian).date(from: dateComponents)
        let subtractUserOffset = Calendar.current.date(byAdding: .minute, value: -userOffset, to: calendarDateFromComponents!)
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: subtractUserOffset!)
    }
        
    fileprivate func dateComponentsAfterSubtractingUserOffset(date: Date, userOffset: Int) -> DateComponents {
        let subtractUserOffset = Calendar.current.date(byAdding: .minute, value: -userOffset, to: date)!
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: subtractUserOffset)
    }
    
    fileprivate func dateAfterAddingUserOffset(date: Date, userOffset: Int) -> Date {
        let addUserOffset = Calendar.current.date(byAdding: .minute, value: userOffset, to: date)!
        return addUserOffset
    }

}
