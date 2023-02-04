//
//  NotificationManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

protocol NotificationManagerProtocol {
    
    func scheduleNotification(_ notification: Notification, userOffset: Int)
    
    func cancelNotification(eventId: String)
    
    func isNotificationScheduled(notificationId: String, completion: @escaping (Bool) -> Void)
    
}
