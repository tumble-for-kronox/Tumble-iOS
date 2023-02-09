//
//  Notification.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-04.
//

import Foundation

struct Notification: Identifiable {
    
    var id: String
    let color: String
    let dateComponents: DateComponents
    let categoryIdentifier: String?
    let content: [String : Any]?

}

enum NotificationContentKey: String {
    case event = "EVENT"
    case color = "COLOR"
}
