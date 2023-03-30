//
//  SideBarToggleButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct NavigationbarSettings: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    let onChangeSchool: (School) -> Void
    let updateBookmarks: () -> Void
    let removeSchedule: (String) -> Void
    
    var body: some View {
        NavigationLink(destination:
                        Settings(
                            viewModel: viewModel,
                            removeSchedule: removeSchedule,
                            updateBookmarks: updateBookmarks,
                            onChangeSchool: onChangeSchool
            
            )
           , label: {
            Image(systemName: "gearshape")
                .navBarIcon()
        })
    }
}

