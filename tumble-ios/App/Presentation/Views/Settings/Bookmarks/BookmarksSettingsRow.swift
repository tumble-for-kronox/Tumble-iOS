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
        HStack {
            Button(action: {deleteBookmark(bookmark.id)}, label: {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(.onSurface)
            })
            .padding(.trailing, 5)
            HStack {
                Toggle(isOn: $bookmark.toggled) {
                    Text(bookmark.id)
                        .font(.system(size: 16))
                }
                .onChange(of: bookmark.toggled) { value in
                    toggleBookmark(bookmark.id, value)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.surface)
            .cornerRadius(10)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
    }
}
