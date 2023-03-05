//
//  HomePageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI

@MainActor final class HomePageViewModel: ObservableObject {
    
    @Inject var preferenceService: PreferenceService
    @Inject var userController: UserController
    
    func makeCanvasUrl() -> URL? {
        return URL(string: preferenceService.getCanvasUrl() ?? "")
    }
    
    
    func makeUniversityUrl() -> URL? {
        return URL(string: preferenceService.getUniversityUrl() ?? "")
    }

}
