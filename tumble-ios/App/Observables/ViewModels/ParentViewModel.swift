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
    
    var viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var preferenceService: PreferenceService
    @Inject var notificationManager: NotificationManager
    @Inject var userController: UserController
    @Inject var schoolManager: SchoolManager
    
    @Published var kronoxUrl: String?
    @Published var canvasUrl: String?
    @Published var domain: String?
    @Published var universityImage: Image?
    @Published var universityName: String?
    
    lazy var homeViewModel: HomeViewModel = viewModelFactory.makeViewModelHome()
    lazy var bookmarksViewModel: BookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
    lazy var accountPageViewModel: AccountViewModel = viewModelFactory.makeViewModelAccount()
    lazy var searchViewModel: SearchViewModel = viewModelFactory.makeViewModelSearch()
    lazy var settingsViewModel: SettingsViewModel = viewModelFactory.makeViewModelSettings()

    lazy var schools: [School] = schoolManager.getSchools()
    
    init() {
               
        self.canvasUrl = preferenceService.getCanvasUrl(schools: schools)
        self.kronoxUrl = preferenceService.getUniversityKronoxUrl(schools: schools)
        self.domain = preferenceService.getUniversityDomain(schools: schools)
        self.universityImage = preferenceService.getUniversityImage(schools: schools)
        self.universityName = preferenceService.getUniversityName(schools: schools)
        
    }
    
    func logOutUser() -> Void {
        userController.logOut()
    }
    
    func updateLocalsAndChildViews() -> Void {
        AppLogger.shared.debug("Updating child views and local university specifics")
        self.kronoxUrl = preferenceService.getUniversityKronoxUrl(schools: schools)
        self.canvasUrl = preferenceService.getCanvasUrl(schools: schools)
        self.domain = preferenceService.getUniversityDomain(schools: schools)
        self.universityImage = preferenceService.getUniversityImage(schools: schools)
        self.universityName = preferenceService.getUniversityName(schools: schools)
        self.searchViewModel.update()
        self.bookmarksViewModel.updateViewLocals()
        self.settingsViewModel.updateViewLocals()
        self.bookmarksViewModel.loadBookmarkedSchedules()
        self.accountPageViewModel.updateViewLocals()
        self.homeViewModel.updateViewLocals()
        
    }
    
    
    func updateSchedulesChildView() -> Void {
        settingsViewModel.updateBookmarks()
        homeViewModel.updateViewLocals()
        bookmarksViewModel.loadBookmarkedSchedules()
    }
    
    func delegateUpdateColorsBookmarks() -> Void {
        bookmarksViewModel.updateCourseColors()
        homeViewModel.updateCourseColors()
    }
    
    func removeSchedule(id: String, completion: @escaping (Bool) -> Void) -> Void {
        scheduleService.remove(scheduleId: id) { result in
            switch result {
            case .success:
                AppLogger.shared.debug("Schedule '\(id)' successfully removed")
                completion(true)
            case .failure:
                AppLogger.shared.critical("Schedule '\(id)' could not be removed")
                completion(false)
            }
        }
    }
    
    func changeSchool(school: School, closure: @escaping (Bool) -> Void) -> Void {
        if school.id == self.preferenceService.getDefaultSchool() {
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
    
    func getSearchViewModel() -> SearchViewModel {
        return viewModelFactory.makeViewModelSearch()
    }
}
