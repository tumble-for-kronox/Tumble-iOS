//
//  DrawerSheetview.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import SwiftUI

enum SideBarSheetViewType {
    case school
    case schedules
    case support
}

struct SideBarSheetView: View {
    let currentSideBarSheetView: SideBarSheetViewType
    let onSelectSchool: (School) -> Void
    let toggleDrawerSheet: () -> Void
    var body: some View {
        switch currentSideBarSheetView {
        case .school:
            SchoolSelectionView(onSelectSchool: { school in
                onSelectSchool(school)
                toggleDrawerSheet()
            })
            
        case .schedules:
            Text("Stub")
        case .support:
            SupportView()
        }
    }
}
