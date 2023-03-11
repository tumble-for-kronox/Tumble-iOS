//
//  SideBarSheetView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import SwiftUI

struct SideBarSheet: View {
    
    @ObservedObject var parentViewModel: SidebarViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let updateBookmarks: () -> Void
    let removeBookmark: (String) -> Void
    let sideBarTabType: SidebarTabType
    let onChangeSchool: (School) -> Void
    @Binding var bookmarks: [Bookmark]?
    
    var body: some View {
        switch sideBarTabType {
        case .school:
            SidebarSheetViewBuilder(header: "Change schools", dismiss: dismiss) {
                SchoolSelection(onSelectSchool: { school in
                    onChangeSchool(school)
                    presentationMode.wrappedValue.dismiss()
                })
            }
        case .bookmarks:
            SidebarSheetViewBuilder(header: "Your bookmarks", dismiss: dismiss) {
                BookmarksSidebarSheet(bookmarks: $bookmarks, toggleBookmark: toggleBookmark, deleteBookmark: deleteBookmark)
            }
        case .support:
            SidebarSheetViewBuilder(header: "Support", dismiss: dismiss) {
                Support()
            }
        case .notifications:
            SidebarSheetViewBuilder(header: "Notifications", dismiss: dismiss) {
                NotificationsSidebarSheet()
            }
        case .none:
            EmptyView()
        case .more:
            SidebarSheetViewBuilder(header: "More", dismiss: dismiss) {
                MoreSidebarSheet()
            }
        default:
            EmptyView()
        }
    }
    
    fileprivate func dismiss() -> Void {
        presentationMode.wrappedValue.dismiss()
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
