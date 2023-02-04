//
//  SideBarSheetView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import SwiftUI

struct SideBarSheetView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let sideBarTabType: SideBarTabType
    let onChangeSchool: (School) -> Void
    
    var body: some View {
        switch sideBarTabType {
        case .school:
            SchoolSelectionView(onSelectSchool: { school in
                onChangeSchool(school)
                presentationMode.wrappedValue.dismiss()
            })
            
        case .bookmarks:
            Text("Stub")
        case .support:
            SupportView()
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
