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

/// ViewModel responsible for performing any startup code,
/// as well as instantiating any other child viewmodels
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
    lazy var accountPageViewModel: AccountViewModel = ViewModelFactory.shared.makeViewModelAccount()
    
    let popupFactory: PopupFactory = PopupFactory.shared
    
    @Published var authSchoolId: Int = -1
    @Published var userNotOnBoarded: Bool = false
        
    private var updatedDuringSession: Bool = false /// Flag checking whether schedules have been attempted to update
    private var schedulesToken: NotificationToken? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNotificationObserver()
        setupPublishers()
        updateRealmSchedules()
    }
    
    /// Creates an observer to listen for the press of a local
    /// notification outside the app, which will then open the respective
    /// event as soon as the user is transferred to the app.
    private func setupNotificationObserver() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(handleEventNotification(_:)),
                name: .eventReceived,
                object: nil
            )
    }
    
    /// Opens a specific `Event` sheet from a local notification
    @objc private func handleEventNotification(_ notification: Notification) {
        if let event = notification.object as? Event {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppController.shared.selectedAppTab = .bookmarks
                AppController.shared.eventSheet = EventDetailsSheetModel(event: event)
            }
        }
    }
    
    /// Initializes any data publishers in order to register changes to comonly
    /// used variables across the app
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
    
    /// Updates any Realm schedules stored locally
    private func updateRealmSchedules() {
        let schedules = realmManager.getAllLiveSchedules()
        if !schedules.isEmpty && !self.updatedDuringSession {
            let scheduleIds = Array(schedules).map { $0.scheduleId }
            Task {
                await self.updateBookmarks(scheduleIds: scheduleIds)
            }
        }
    }

    /// Toggles the onboarding preference parameter
    func finishOnboarding() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.preferenceService.setUserOnboarded()
        }
    }
    
    /// Attempts to update the locally stored schedules
    /// by retrieving all the schedules from the Tumble backend.
    @MainActor
    func updateBookmarks(scheduleIds: [String]) async {
        defer { self.updatedDuringSession = true } /// Always claim update during startup, even if failed
        var updatedSchedules = 0
        let scheduleCount: Int = scheduleIds.count

        for scheduleId in scheduleIds {
            if let schedule = self.realmManager.getScheduleByScheduleId(scheduleId: scheduleId), self.validUpdateRequest(schedule: schedule) {
                let scheduleId: String = schedule.scheduleId
                let schoolId = schedule.schoolId
                let endpoint: Endpoint = .schedule(scheduleId: scheduleId, schoolId: schoolId)

                do {
                    let fetchedSchedule: Response.Schedule = try await kronoxManager.get(endpoint)
                    self.updateSchedule(schedule: fetchedSchedule, schoolId: schoolId, existingSchedule: schedule)
                    updatedSchedules += 1
                } catch {
                    AppLogger.shared.error("Updating could not finish due to network error")
                }
            } else {
                AppLogger.shared.error("Can not update schedule. Requires authentication against different university")
            }
        }

        if updatedSchedules != scheduleCount {
            PopupToast(popup: popupFactory.updateBookmarksFailed()).showAndStack()
        }
    }


    /// Checks if a requested update for a school is valid, since some
    /// schools require authorization for viewing and fetching schedules
    func validUpdateRequest(schedule: Schedule) -> Bool {
        let validRequest: Bool = (schedule.requiresAuth && String(authSchoolId) == schedule.schoolId) || !schedule.requiresAuth
        return validRequest
    }
    
    /// Updates an individual schedule and its course colors.
    @MainActor func updateSchedule(
        schedule: Response.Schedule,
        schoolId: String,
        existingSchedule: Schedule
    ) {
        let scheduleRequiresAuth = existingSchedule.requiresAuth
        let realmSchedule: Schedule = schedule.toRealmSchedule(
            scheduleRequiresAuth: scheduleRequiresAuth,
            schoolId: schoolId,
            existingCourseColors: self.realmManager.getCourseColors()
        )
        self.realmManager.updateSchedule(scheduleId: schedule.id, newSchedule: realmSchedule)
    }
    
    
    /// Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
        cancellables.forEach { $0.cancel() }
    }

}
