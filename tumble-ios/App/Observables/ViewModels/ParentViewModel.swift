//
//  File.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI


// Parent/Container for other viewmodels
final class ParentViewModel: ObservableObject {
    
    var viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    lazy var homeViewModel: HomeViewModel = viewModelFactory.makeViewModelHome()
    lazy var bookmarksViewModel: BookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
    lazy var accountPageViewModel: AccountViewModel = viewModelFactory.makeViewModelAccount()
    lazy var searchViewModel: SearchViewModel = viewModelFactory.makeViewModelSearch()
    lazy var settingsViewModel: SettingsViewModel = viewModelFactory.makeViewModelSettings()
    
}
