//
//  tumble_iosUITests.swift
//  tumble-iosUITests
//
//  Created by Adis Veletanlic on 3/31/23.
//

import XCTest
@testable import PermissionsSwiftUI
@testable import CorePermissionsSwiftUI
import SwiftUI
import PermissionsSwiftUINotification


final class OnBoardingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testPermissionSheet() throws {
        let app = XCUIApplication()
        app.launch()
        var store = PermissionComponentsStore()
        let notificationPermission = store.getPermissionComponent(for: .notification, modify: {_ in })
        XCTAssertEqual(notificationPermission, JMPermission(
            imageIcon: AnyView(Image(systemName: "bell.fill")),
            title: "Notification",
            description: "Allow to send notifications",
            authorized: false
        ))
    }
}
