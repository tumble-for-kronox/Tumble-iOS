//
//  DrawerSheetview.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import SwiftUI

enum DrawerSheetViewType {
    case school
    case schedules
    case support
}

struct DrawerSheetView: View {
    let currentDrawerSheetView: DrawerSheetViewType
    let onSelectSchool: (School) -> Void
    let toggleDrawerSheet: () -> Void
    var body: some View {
        switch currentDrawerSheetView {
        case .school:
            SchoolSelectViewForSheet(selectSchoolCallback: { school in
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
