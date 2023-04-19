//
//  BookmarksSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI
import RealmSwift

struct BookmarksSettings: View {
    
    @ObservedObject var parentViewModel: SettingsViewModel
    @ObservedResults(Schedule.self) var schedules
    
    var body: some View {
        if !schedules.isEmpty {
            CustomList {
                ForEach(schedules.indices, id: \.self) { index in
                    BookmarkSettingsRow(
                        schedule: schedules[index],
                        index: index,
                        onDelete: onDelete
                    )
                }
            }

        } else {
            Info(title: NSLocalizedString("No bookmarks yet", comment: ""), image: "bookmark.slash")
        }
    }
    
    func onDelete(at offsets: IndexSet, for id: String) {
        let assignedEvents = Array(schedules).flatMap { $0.days }.flatMap { $0.events }
        parentViewModel.removeNotificationsFor(for: id, referencing: assignedEvents)
        $schedules.remove(atOffsets: offsets)
    }
    
}
