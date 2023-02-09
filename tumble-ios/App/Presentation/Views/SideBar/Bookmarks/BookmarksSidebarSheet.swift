//
//  BookmarksSidebarSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import SwiftUI

struct BookmarksSidebarSheet: View {
    
    @Binding var bookmarks: [Bookmark]?
    let toggleBookmark: (String, Bool) -> Void
    let deleteBookmark: (String) -> Void
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack {
                if bookmarks != nil {
                    if !bookmarks!.isEmpty {
                        ForEach(bookmarks!, id: \.id) { bookmark in
                            BookmarkRow(bookmark: bookmark, toggleBookmark: toggleBookmark, deleteBookmark: deleteBookmark)
                        }
                    } else {
                        Info(title: "No bookmarks yet", image: "bookmark.slash")
                    }
                }
            }
        }
    }
}
