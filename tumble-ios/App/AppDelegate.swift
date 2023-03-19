//
//  AppDelegate.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import Foundation
import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // This function will be called right after user tap on the notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
            
            let userInfo = response.notification.request.content.userInfo
            let event: Response.Event = (userInfo[NotificationContentKey.event.rawValue] as! [String : Any]).toEvent()!
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppController.shared.selectedAppTab = .bookmarks
                AppController.shared.eventSheet = EventDetailsSheetModel(event: event, color: (userInfo[NotificationContentKey.color.rawValue] as! String).toColor())
            }
            
            completionHandler()
    }
    
    // Handle notification attributes when app is in foreground/background mode
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
        completionHandler([.banner, .list, .badge, .sound])
    }
}
