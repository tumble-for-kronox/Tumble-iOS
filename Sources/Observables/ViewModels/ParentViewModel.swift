//
//  ParentViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Combine
import Foundation
import RealmSwift
import SwiftUI

/// Also acts as delegator for other viewmodels
final class ParentViewModel: ObservableObject {
    var viewModelFactory: ViewModelFactory = .shared
    
    @Inject private var preferenceService: PreferenceService
    @Inject private var kronoxManager: KronoxManager
    @Inject private var schoolManager: SchoolManager
    @Inject private var realmManager: RealmManager
    
    lazy var homeViewModel: HomeViewModel = viewModelFactory.makeViewModelHome()
    lazy var bookmarksViewModel: BookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
    lazy var searchViewModel: SearchViewModel = viewModelFactory.makeViewModelSearch()
    lazy var settingsViewModel: SettingsViewModel = viewModelFactory.makeViewModelSettings()
    
    let accountPageViewModel: AccountViewModel
    
    @Published var authSchoolId: Int = -1
    @Published var userNotOnBoarded: Bool = false
        
    private var updatedDuringSession: Bool = false
    private var schedulesToken: NotificationToken? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Do not lazy load account page
        accountPageViewModel = viewModelFactory.makeViewModelAccount()
        
        setupPublishers()
        
        setupRealmListener()
    }
    
    private func setupPublishers() {
        let authSchoolIdPublisher = preferenceService.$authSchoolId.receive(on: RunLoop.main)
        let onBoardingPublisher = preferenceService.$userOnBoarded.receive(on: RunLoop.main)
        
        Publishers.CombineLatest(authSchoolIdPublisher, onBoardingPublisher)
            .sink { [weak self] authSchoolId, userOnBoarded in
                self?.userNotOnBoarded = !userOnBoarded
                self?.authSchoolId = authSchoolId
            }
            .store(in: &cancellables)
    }
    
    private func setupRealmListener() {
        let schedules = realmManager.getAllLiveSchedules()
        schedulesToken = schedules.observe { [weak self] changes in
            guard let self else { return }
            switch changes {
            case .initial(let results), .update(let results, _, _, _):
                if !results.isEmpty && !self.updatedDuringSession {
                    self.updateBookmarks(schedules: Array(results))
                }
            case .error:
                fatalError()
            }
        }
    }
    
    func finishOnboarding() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.preferenceService.setUserOnboarded()
        }
    }
    
    func updateBookmarks(schedules: [Schedule]) {
        defer { self.updatedDuringSession = true } /// Always claim update during startup, even if failed
        var updatedSchedules = 0
        let scheduleCount: Int = schedules.count
        let group = DispatchGroup() /// Create a DispatchGroup
        
        for schedule in schedules {
            if validUpdateRequest(schedule: schedule) {
                let scheduleId: String = schedule.scheduleId
                let schoolId = schedule.schoolId
                let endpoint: Endpoint = .schedule(scheduleId: scheduleId, schoolId: schoolId)
                
                group.enter()
                
                /// Fetch schedule from backend
                let _ = kronoxManager.get(
                    endpoint, then: { [weak self] (result: Result<Response.Schedule, Response.ErrorMessage>) in
                        defer { group.leave() }
                        
                        switch result {
                        case .success(let fetchedSchedule):
                            AppLogger.shared.debug("Updated schedule with id: \(fetchedSchedule.id)")
                            self?.updateSchedule(schedule: fetchedSchedule, schoolId: schoolId, schedules: schedules)
                            updatedSchedules += 1
                        case .failure(let failure):
                            AppLogger.shared.error("Updating could not finish due to network error: \(failure)")
                        }
                    }
                )
            } else {
                AppLogger.shared.error("Can not update schedule. Requires authentication against different university")
            }
        }
        
        group.notify(queue: .main) {
            if updatedSchedules != scheduleCount {
                AppController.shared.toast = Toast(
                    type: .info,
                    title: NSLocalizedString("Information", comment: ""),
                    message: NSLocalizedString("Some schedules could not be updated. Either due to missing authorization or network errors", comment: "")
                )
            }
        }
    }

    func validUpdateRequest(schedule: Schedule) -> Bool {
        let validRequest: Bool = (schedule.requiresAuth && String(authSchoolId) == schedule.schoolId) || !schedule.requiresAuth
        return validRequest
    }
    
    func updateSchedule(
        schedule: Response.Schedule,
        schoolId: String,
        schedules: [Schedule]
    ) {
        if let scheduleRequiresAuth: Bool = schedules.first(where: { $0.scheduleId == schedule.id })?.requiresAuth {
            let realmSchedule: Schedule = schedule.toRealmSchedule(
                scheduleRequiresAuth: scheduleRequiresAuth,
                schoolId: schoolId,
                existingCourseColors: realmManager.getCourseColors()
            )
            realmManager.updateSchedule(scheduleId: schedule.id, newSchedule: realmSchedule)
        }
    }
}
