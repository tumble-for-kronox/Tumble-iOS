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
            let sortedBookmarks = schedules.sorted(by: { $0.id < $1.id })
            CustomList {
                ForEach(sortedBookmarks.indices, id: \.self) { index in
                    BookmarkSettingsRow(
                        schedule: sortedBookmarks[index],
                        index: index,
                        onDelete: onDelete
                    )
                }
            }

        } else {
            Info(title: NSLocalizedString("No bookmarks yet", comment: ""), image: "bookmark.slash")
        }
    }
    
    func onDelete(at offsets: IndexSet) {
        $schedules.remove(atOffsets: offsets)
    }
    
}
