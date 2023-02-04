//
//  NotificationManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

protocol NotificationManagerProtocol {
    
    func scheduleNotification(for notification: Notification, userOffset: Int)
    
    func cancelNotification(for eventId: String)
    
    func cancelNotifications(with categoryIdentifier: String)
    
    func isNotificationScheduled(categoryIdentifier: String, completion: @escaping (Bool) -> Void) -> Void
    
    func isNotificationScheduled(eventId: String, completion: @escaping (Bool) -> Void) -> Void
    
}
