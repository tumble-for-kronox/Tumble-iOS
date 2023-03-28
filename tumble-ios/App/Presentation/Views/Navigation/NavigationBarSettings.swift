//
//  SideBarToggleButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct NavigationBarSettings: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    let onChangeSchool: (School) -> Void
    let updateBookmarks: () -> Void
    let removeBookmark: (String) -> Void
    
    var body: some View {
        NavigationLink(destination:
                        Settings(
                            viewModel: viewModel,
                            removeBookmark: removeBookmark,
                            updateBookmarks: updateBookmarks,
                            onChangeSchool: onChangeSchool
            
            )
           , label: {
            Image(systemName: "gearshape")
                .navBarIcon()
        })
    }
}

