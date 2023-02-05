//
//  File.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

enum ThemeMode: String {
    case light = "light"
    case dark = "dark"
}


// Parent/Container for other viewmodels and common methods
// to update the AppView and its child views through their viewmodels
@MainActor final class ParentViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var preferenceService: PreferenceService
    @Inject var notificationManager: NotificationManager
    
    @Published var universityImage: Image?
    @Published var universityName: String?
    @Published var kronoxUrl: String?
    @Published var canvasUrl: String?
    @Published var domain: String?

    let homeViewModel: HomeView.HomeViewModel
    let bookmarksViewModel: BookmarksView.BookmarksViewModel
    let accountPageViewModel: AccountPageView.AccountPageViewModel
    
    init() {
        
        // ViewModels to subviews
        self.homeViewModel = viewModelFactory.makeViewModelHomePage()
        self.bookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
        self.accountPageViewModel = viewModelFactory.makeViewModelAccountPage()
        
        self.universityName = preferenceService.getUniversityName()
        self.universityImage = preferenceService.getUniversityImage()
        self.canvasUrl = preferenceService.getCanvasUrl()
        self.kronoxUrl = preferenceService.getUniversityKronoxUrl()
        self.domain = preferenceService.getUniversityDomain()
    }
    
    func updateUniversityLocalsForView() -> Void {
        self.universityImage = preferenceService.getUniversityImage()
        self.universityName = preferenceService.getUniversityName()
        self.kronoxUrl = preferenceService.getUniversityKronoxUrl()
        self.canvasUrl = preferenceService.getCanvasUrl()
        self.domain = preferenceService.getUniversityDomain()
    }
    
    func generateViewModelEventSheet(event: Response.Event, color: Color) -> EventDetailsSheetView.EventDetailsViewModel {
        return viewModelFactory.makeViewModelEventDetailsSheet(event: event, color: color)
    }
    
    func updateSchedulesChildView() -> Void {
        bookmarksViewModel.loadSchedules()
    }
    
    func changeSchool(school: School, closure: @escaping () -> Void) -> Void {
        preferenceService.setSchool(id: school.id, closure: { [weak self] in
            self?.removeAllSchedules()
            self?.removeAllCourseColors()
            self?.cancelAllNotifications()
            closure()
        })
    }
    
    fileprivate func removeAllCourseColors() -> Void {
        self.courseColorService.removeAll { result in
            switch result {
            case .failure(let error):
                // TODO: Add error message for user
                AppLogger.shared.info("Could not remove course colors: \(error)")
            case .success:
                // TODO: Add success message for user
                AppLogger.shared.info("Removed all course colors from local storage")
            }
        }
    }
    
    fileprivate func removeAllSchedules() -> Void {
        scheduleService.removeAll { result in
            switch result {
            case .failure(let error):
                // TODO: Add error message for user
                AppLogger.shared.info("Could not remove schedules: \(error)")
            case .success:
                // TODO: Add success message for user
                AppLogger.shared.info("Removed all schedules from local storage")
                
            }
        }
    }
    
    fileprivate func cancelAllNotifications() -> Void {
        notificationManager.cancelNotifications()
    }
}