//
//  NotificationsSidebarSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-10.
//

import SwiftUI

struct NotificationsSidebarSheet: View {
    var body: some View {
        // List of options for notifications
        VStack {
            SidebarSheetButton(image: "bell.slash", title: "Clear all notifications", onClick: {})
            SidebarSheetButton(image: "bell.badge", title: "Set notifications for all schedules", onClick: {})
        }
    }
}

struct NotificationsSidebarSheet_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSidebarSheet()
    }
}
