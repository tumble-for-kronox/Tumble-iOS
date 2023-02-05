//
//  NotificationManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

protocol NotificationManagerProtocol {
    
    func scheduleNotification(for notification: Notification, userOffset: Int, completion: @escaping (Result<Int, NotificationError>) -> Void)
    
    func cancelNotification(for eventId: String)
    
    func cancelNotifications(with categoryIdentifier: String)
    
    func cancelNotifications() -> Void
    
    func isNotificationScheduled(categoryIdentifier: String, completion: @escaping (Bool) -> Void) -> Void
    
    func isNotificationScheduled(eventId: String, completion: @escaping (Bool) -> Void) -> Void
    
}
