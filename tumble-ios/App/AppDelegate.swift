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

/// This AppDelegate does not take into consideration devices
/// that are below iOS 10, delegates are set accordingly.
class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

          if let messageID = userInfo[gcmMessageIDKey] {
              AppLogger.shared.info("Message ID: \(messageID)")
          }

          AppLogger.shared.info("\(userInfo)")

          completionHandler(UIBackgroundFetchResult.newData)
        }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

      let deviceToken: [String: String] = ["token": fcmToken ?? ""]
        AppLogger.shared.debug("Device token: \(deviceToken)")
        if deviceToken["token"] != nil {
            Messaging.messaging().subscribe(toTopic: "updates") { error in
                if let error = error {
                    AppLogger.shared.info("Failed to subscribe to news topic: \(error.localizedDescription)", source: "AppDelegate")
                } else {
                    AppLogger.shared.info("Subscribed to news topic", source: "AppDelegate")
                }
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

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppLogger.shared.critical("Failed to register for remote notifications for the current device token: \(deviceToken)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppLogger.shared.critical("Failed to register for remote notifications: \(error)")
    }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        if let event = (userInfo[NotificationContentKey.event.rawValue] as! [String : Any]).toEvent() {
            // Message successully parsed as Event, which means it was a local notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppController.shared.selectedAppTab = .bookmarks
                AppController.shared.eventSheet = EventDetailsSheetModel(
                    event: event,
                    color: (userInfo[NotificationContentKey.color.rawValue] as! String).toColor())
            }
        }
        
        if let messageID = userInfo[gcmMessageIDKey] {
            AppLogger.shared.info("Message ID from userNotificationCenter didReceive: \(messageID)")
        }

        completionHandler()
  }
}
