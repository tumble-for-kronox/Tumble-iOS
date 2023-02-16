//
//  File.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI


// Parent/Container for other viewmodels and common methods
// to update the AppView and its child views through their viewmodels
@MainActor final class ParentViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var preferenceService: PreferenceService
    @Inject var notificationManager: NotificationManager
    
    @Published var kronoxUrl: String?
    @Published var canvasUrl: String?
    @Published var domain: String?
    @Published var universityImage: Image?
    @Published var universityName: String?
    @Published var userModel: User = User()
    
    let homeViewModel: HomePage.HomePageViewModel
    let bookmarksViewModel: BookmarkPage.BookmarkPageViewModel
    let accountPageViewModel: AccountPage.AccountPageViewModel
    let searchViewModel: SearchPage.SearchPageViewModel
    let sidebarViewModel: SidebarMenu.SidebarViewModel

    
    init() {
        
        // ViewModels to subviews
        self.homeViewModel = viewModelFactory.makeViewModelHomePage()
        self.bookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
        self.accountPageViewModel = viewModelFactory.makeViewModelAccountPage()
        self.searchViewModel = viewModelFactory.makeViewModelSearch()
        self.sidebarViewModel = viewModelFactory.makeViewModelSidebar()
        
        self.canvasUrl = preferenceService.getCanvasUrl()
        self.kronoxUrl = preferenceService.getUniversityKronoxUrl()
        self.domain = preferenceService.getUniversityDomain()
        self.universityImage = preferenceService.getUniversityImage()
        self.universityName = preferenceService.getUniversityName()
        
        self.userModel.autoLogin()
    }
    
    
    func updateLocalsAndChildViews() -> Void {
        AppLogger.shared.info("Updating child views and local university specifics")
        self.kronoxUrl = preferenceService.getUniversityKronoxUrl()
        self.canvasUrl = preferenceService.getCanvasUrl()
        self.domain = preferenceService.getUniversityDomain()
        self.universityImage = preferenceService.getUniversityImage()
        self.universityName = preferenceService.getUniversityName()
        self.searchViewModel.update()
        self.bookmarksViewModel.updateViewLocals()
        self.sidebarViewModel.updateViewLocals()
        self.bookmarksViewModel.loadBookmarkedSchedules()
        self.accountPageViewModel.updateViewLocals()
        
        self.userModel.autoLogin()
    }
    
    
    func updateSchedulesChildView() -> Void {
        sidebarViewModel.updateBookmarks()
        bookmarksViewModel.loadBookmarkedSchedules()
    }
    
    func removeSchedule(id: String, completion: @escaping (Bool) -> Void) -> Void {
        scheduleService.remove(scheduleId: id) { result in
            switch result {
            case .success(_):
                AppLogger.shared.info("Schedule '\(id)' successfully removed")
                completion(true)
            case .failure(_):
                AppLogger.shared.info("Schedule '\(id)' could not be removed")
                completion(false)
            }
        }
    }
    
    func changeSchool(school: School, closure: @escaping (Bool) -> Void) -> Void {
        if school == self.preferenceService.getDefaultSchool() {
            closure(false)
        } else {
            self.preferenceService.setSchool(id: school.id, closure: { [weak self] in
                guard let self = self else { return }
                self.removeAllSchedules() {
                    self.removeAllCourseColors() {
                        self.preferenceService.setBookmarks(bookmarks: [])
                        self.cancelAllNotifications() {
                            closure(true)
                        }
                    }
                }
            })
        }
    }
    
    func getSearchViewModel() -> SearchPage.SearchPageViewModel {
        return viewModelFactory.makeViewModelSearch()
    }
}




extension ParentViewModel {
    
    fileprivate func removeAllCourseColors(completion: @escaping () -> Void) -> Void {
        self.courseColorService.removeAll { result in
            switch result {
            case .failure(let error):
                // TODO: Add error message for user
                AppLogger.shared.info("Could not remove course colors: \(error)")
            case .success:
                // TODO: Add success message for user
                AppLogger.shared.info("Removed all course colors from local storage")
                completion()
            }
        }
    }
    
    
    fileprivate func removeAllSchedules(completion: @escaping () -> Void) -> Void {
        scheduleService.removeAll { result in
            switch result {
            case .failure(let error):
                // TODO: Add error message for user
                AppLogger.shared.info("Could not remove schedules: \(error)")
            case .success:
                // TODO: Add success message for user
                AppLogger.shared.info("Removed all schedules from local storage")
                completion()
            }
        }
    }
    
    fileprivate func cancelAllNotifications(completion: @escaping () -> Void) -> Void {
        notificationManager.cancelNotifications()
        completion()
    }
}
