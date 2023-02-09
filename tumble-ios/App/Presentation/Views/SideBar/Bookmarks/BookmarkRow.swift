//
//  BookmarkRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import SwiftUI

struct BookmarkRow: View {
    
    @ObservedObject var bookmark: Bookmark
    let toggleBookmark: (String, Bool) -> Void
    
    var body: some View {
        VStack {
            Toggle(isOn: $bookmark.toggled) {
                HStack (alignment: .center, spacing: 0) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 24))
                        .foregroundColor(.onBackground)
                    Text(bookmark.id)
                        .font(.system(size: 18, design: .rounded))
                        .padding(15)
                    Spacer()
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .primary))
            .onChange(of: bookmark.toggled) { value in
                toggleBookmark(bookmark.id, value)
            }
            Divider()
        }
        .padding()
    }
}


