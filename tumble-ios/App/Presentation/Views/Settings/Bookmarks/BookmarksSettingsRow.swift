//
//  BookmarksSettingsRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI

struct BookmarkSettingsRow: View {
    
    @ObservedObject var bookmark: Bookmark
    let toggleBookmark: (String, Bool) -> Void
    let deleteBookmark: (String) -> Void
    
    var body: some View {
        Toggle(isOn: $bookmark.toggled) {
            Text(bookmark.id)
                .font(.system(size: 16))
                .padding(15)
        }
        .id(bookmark.id)
        .swipeActions(content: {
            Button(action: {
                deleteBookmark(bookmark.id)
            }, label: {
                Image(systemName: "trash")
                    .frame(width: 25, height: 25)
                    .foregroundColor(.onPrimary)
            })
            .tint(.red)
        })
        .onChange(of: bookmark.toggled) { value in
            toggleBookmark(bookmark.id, value)
        }
    }
}
