//
//  SideBarSheetView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import SwiftUI

struct SideBarSheet: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let sideBarTabType: SidebarTabType
    let onChangeSchool: (School) -> Void
    
    var body: some View {
        switch sideBarTabType {
        case .school:
            SchoolSelection(onSelectSchool: { school in
                onChangeSchool(school)
                presentationMode.wrappedValue.dismiss()
            })
            
        case .bookmarks:
            Text("Stub")
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
        }
    }
}
