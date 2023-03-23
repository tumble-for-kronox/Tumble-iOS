//
//  AppDelegate.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
                        
            FirebaseApp.configure()
            Messaging.messaging().delegate = self

            if #available(iOS 10.0, *) {
              // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
            } else {
              let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
              application.registerUserNotificationSettings(settings)
            }
            application.registerForRemoteNotifications()
            return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

          if let messageID = userInfo[gcmMessageIDKey] {
              AppLogger.shared.info("Message ID: \(messageID)", source: "AppDelegate")
          }

          AppLogger.shared.info("\(userInfo)")

          completionHandler(UIBackgroundFetchResult.newData)
        }
}

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?) {
            let deviceToken: [String: String] = ["token": fcmToken ?? ""]
            AppLogger.shared.info("Device token: \(deviceToken)", source: "AppDelegate") // Unique user device token for remote FCM
            if deviceToken["token"] != nil {
                Messaging.messaging().subscribe(toTopic: "news") { error in
                    AppLogger.shared.info("Failed to subscribe to news topic", source: "AppDelegate")
                }
            }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10+ devices.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .badge, .list, .sound]])
  }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppLogger.shared.info("Registered for remote notifications device token: \(deviceToken)", source: "AppDelegate")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppLogger.shared.critical("Failed to register for remote notifications: \(error)", source: "AppDelegate")
    }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        AppLogger.shared.info("\(userInfo)")
        if let event = (userInfo[NotificationContentKey.event.rawValue] as! [String : Any]).toEvent() {
            // Message successully parsed as Event, which means it was a local notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppController.shared.selectedAppTab = .bookmarks
                AppController.shared.eventSheet = EventDetailsSheetModel(
                    event: event,
                    color: (userInfo[NotificationContentKey.color.rawValue] as! String).toColor())
            }
        }
        
        else if let messageID = userInfo[gcmMessageIDKey] {
            AppLogger.shared.info("Message ID from userNotificationCenter didReceive: \(messageID)", source: "AppDelegate")
        }

        completionHandler()
    }
}
