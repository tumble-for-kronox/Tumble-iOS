//
//  Notification+NameExtension.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-02.
//

import Foundation

extension Notification.Name {
    static let eventReceived = Notification.Name("eventReceived")
    static let resourceBooked = Notification.Name("resourceBooked")
    static let unBlurOneTimePopup = Notification.Name("unBlurPopup")
    static let updateSchedulesToNewFormat = Notification.Name("updateSchedulesToNewFormat")
}
