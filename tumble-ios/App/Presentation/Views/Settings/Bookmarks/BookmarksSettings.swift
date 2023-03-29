//
//  BookmarksSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI

struct BookmarksSettings: View {
    @Binding var bookmarks: [Bookmark]?
    let toggleBookmark: (String, Bool) -> Void
    let deleteBookmark: (String) -> Void
    
    var body: some View {
        VStack {
            if bookmarks != nil {
                if !bookmarks!.isEmpty {
                    ScrollView (showsIndicators: false) {
                        ForEach(bookmarks!, id: \.id) { bookmark in
                            BookmarkSettingsRow(bookmark: bookmark, toggleBookmark: toggleBookmark, deleteBookmark: deleteBookmark)
                        }
                    }
                } else {
                    Info(title: "No bookmarks yet", image: "bookmark.slash")
                }
            }
        }
    }
}
