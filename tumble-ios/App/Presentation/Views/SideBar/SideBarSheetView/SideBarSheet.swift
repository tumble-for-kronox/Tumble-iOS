//
//  SideBarSheetView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import SwiftUI

struct SideBarSheet: View {
    
    @ObservedObject var parentViewModel: SidebarMenu.SidebarViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let updateBookmarks: () -> Void
    let removeBookmark: (String) -> Void
    let sideBarTabType: SidebarTabType
    let onChangeSchool: (School) -> Void
    @Binding var bookmarks: [Bookmark]?
    
    var body: some View {
        switch sideBarTabType {
        case .school:
            SidebarSheetViewBuilder(header: "Change schools") {
                SchoolSelection(onSelectSchool: { school in
                    onChangeSchool(school)
                    presentationMode.wrappedValue.dismiss()
                })
            }
        case .bookmarks:
            SidebarSheetViewBuilder(header: "Your bookmarks") {
                BookmarksSidebarSheet(bookmarks: $bookmarks, toggleBookmark: toggleBookmark, deleteBookmark: deleteBookmark)
            }
        case .support:
            Support()
        case .none:
            EmptyView()
        case .notifications:
            EmptyView()
        case .more:
            EmptyView()
        case .logOut:
            EmptyView()
        case .logIn:
            EmptyView()
        }
    }
    
    fileprivate func toggleBookmark(id: String, value: Bool) -> Void {
        parentViewModel.toggleBookmarkVisibility(for: id, to: value)
        updateBookmarks()
    }
    
    fileprivate func deleteBookmark(id: String) -> Void {
        parentViewModel.deleteBookmark(id: id)
        removeBookmark(id)
    }
}
