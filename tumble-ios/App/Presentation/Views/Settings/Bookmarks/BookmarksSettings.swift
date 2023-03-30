//
//  BookmarksSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI

struct BookmarksSettings: View {
    
    @ObservedObject var parentViewModel: SettingsViewModel
    let updateBookmarks: () -> Void
    let removeSchedule: (String) -> Void
    
    var body: some View {
        if let bookmarks = parentViewModel.bookmarks {
            if !bookmarks.isEmpty {
                let sortedBookmarks = bookmarks.sorted(by: { $0.id < $1.id })
                List {
                    ForEach(sortedBookmarks, id: \.id) { bookmark in
                        BookmarkSettingsRow(
                            bookmark: bookmark,
                            toggleBookmark: toggleBookmark,
                            deleteBookmark: deleteBookmark
                        )
                    }
                }
            } else {
                Info(title: "No bookmarks yet", image: "bookmark.slash")
            }
        }
    }
    
    fileprivate func deleteBookmark(id: String) -> Void {
        parentViewModel.deleteBookmark(id: id)
        // Also remove schedule from scheduleservice
        removeSchedule(id)
    }
    
    fileprivate func toggleBookmark(id: String, toggled: Bool) -> Void {
        parentViewModel.toggleBookmarkVisibility(for: id, to: toggled)
        updateBookmarks()
    }

}
