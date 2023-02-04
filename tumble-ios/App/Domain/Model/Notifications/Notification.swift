//
//  Notification.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-04.
//

import Foundation

struct Notification: Identifiable {
    var id: String
    let title: String
    let subtitle: String
    let dateComponents: DateComponents
    let categoryIdentifier: String?
}
