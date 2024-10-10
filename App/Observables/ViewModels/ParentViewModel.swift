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
    @Inject private var networkController: Network
    
    lazy var homeViewModel: HomeViewModel = viewModelFactory.makeViewModelHome()
    lazy var bookmarksViewModel: BookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
    lazy var searchViewModel: SearchViewModel = viewModelFactory.makeViewModelSearch()
    lazy var settingsViewModel: SettingsViewModel = viewModelFactory.makeViewModelSettings()
    lazy var accountPageViewModel: AccountViewModel = ViewModelFactory.shared.makeViewModelAccount()
    
    let popupFactory: PopupFactory = .shared
    let appController: AppController = .shared
    
    @Published var authSchoolId: Int = -1
    @Published var userNotOnBoarded: Bool = false
    @Published var updateAttempted: Bool = false
    @Published var showingOneTimePopup: Bool = false
        
    private var schedulesToken: NotificationToken? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNotificationObservers()
        setupPublishers()
        checkOneTimeDevPopup()
    }
    
    private func checkOneTimeDevPopup() {
        if preferenceService.showOneTimePopup() {
            showingOneTimePopup = true
            OneTimePopup().showAndStack()
            preferenceService.setShowOneTimePopup(show: false)
        }
    }
    
    /// Creates two observers for event notifications
    private func setupNotificationObservers() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(handleUnBlurPopup(_:)),
                name: .unBlurOneTimePopup,
                object: nil
            )
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(handleEventNotification(_:)),
                name: .eventReceived,
                object: nil
            )
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(updateAllSchedulesToNewFormat(_:)),
                name: .updateSchedulesToNewFormat,
                object: nil
            )
    }
    
    @objc private func updateAllSchedulesToNewFormat(_ notification: Notification) {
        self.updateRealmSchedules()
    }
    
    /// De-blurs background after popup
    @objc private func handleUnBlurPopup(_ notifcation: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.showingOneTimePopup = false
        }
    }
    
    /// Opens a specific `Event` sheet from a local notification
    @objc private func handleEventNotification(_ notification: Notification) {
        if let event = notification.object as? Event {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.appController.selectedAppTab = .bookmarks
                self?.appController.eventSheet = EventDetailsSheetModel(event: event)
            }
        }
    }
    
    /// Initializes any data publishers in order to register changes to comonly
    /// used variables across the app
    private func setupPublishers() {
        let authSchoolIdPublisher = preferenceService.$authSchoolId.receive(on: RunLoop.main)
        let onBoardingPublisher = preferenceService.$userOnBoarded.receive(on: RunLoop.main)
        let networkConnectionPublisher = networkController.$connected.receive(on: RunLoop.main)
        
        Publishers.CombineLatest3(authSchoolIdPublisher, onBoardingPublisher, networkConnectionPublisher)
            .sink { [weak self] authSchoolId, userOnBoarded, connected in
                guard let self = self else { return }
                self.userNotOnBoarded = !userOnBoarded
                self.authSchoolId = authSchoolId

                if connected && self.updateShouldOccur() && !appController.isUpdatingBookmarks && !updateAttempted {
                    AppLogger.shared.debug("Updating all bookmarks ...")
                    self.updateRealmSchedules()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateShouldOccur() -> Bool {
        if let lastUpdate = preferenceService.getLastUpdated() {
            if let threeHoursAgo = Calendar.current.date(byAdding: .hour, value: -3, to: Date.now) {
                if lastUpdate <= threeHoursAgo {
                    return true
                } else {
                    return false
                }
            }
        }
        return true
    }
    
    /// Attempts to update the locally stored schedules
    /// by retrieving all the schedules by id from the backend.
    @MainActor
    func updateBookmarks(scheduleIds: [String]) async {
        
        appController.isUpdatingBookmarks = true
        
        defer {
            self.preferenceService.setLastUpdated(time: Date())
            self.appController.isUpdatingBookmarks = false
            self.updateAttempted = true
        }
        
        var updatedSchedules = 0
        let scheduleCount: Int = scheduleIds.count
        
        for scheduleId in scheduleIds {
            do {
                try await fetchAndUpdateSchedule(scheduleId: scheduleId)
                updatedSchedules += 1
            } catch {
                AppLogger.shared.error("Updating could not finish due to network error or other issue")
            }
        }
        
        if updatedSchedules != scheduleCount {
            PopupToast(popup: popupFactory.updateBookmarksFailed()).showAndStack()
        }
        
        AppLogger.shared.debug("Finished updating schedules")
    }

    
    @MainActor
    private func fetchAndUpdateSchedule(scheduleId: String) async throws {
        guard let schedule = realmManager.getScheduleByScheduleId(scheduleId: scheduleId), !schedule.isInvalidated else {
            throw UpdateBookmarkError.scheduleNotFound(scheduleId)
        }

        do {
            let endpoint: Endpoint = .schedule(scheduleId: schedule.scheduleId, schoolId: schedule.schoolId)
            let fetchedSchedule: Response.Schedule = try await kronoxManager.get(endpoint)
            await updateSchedule(schedule: fetchedSchedule, schoolId: schedule.schoolId, existingSchedule: schedule)
            
            guard !schedule.isInvalidated else {
                throw UpdateBookmarkError.scheduleNotFound(scheduleId)
            }
        } catch {
            if schedule.isInvalidated {
                throw UpdateBookmarkError.scheduleNotFound(scheduleId)
            } else {
                throw UpdateBookmarkError.networkError(error.localizedDescription)
            }
        }
    }
    
    
    /// Updates any Realm schedules stored locally
    private func updateRealmSchedules() {
        // Get schedules from Realm database
        let schedules = realmManager.getAllLiveSchedules()
        if !schedules.isEmpty {
            // Filter out invalidated schedules and get their IDs
            let scheduleIds = Array(schedules).filter { !$0.isInvalidated }.map { $0.scheduleId }
            
            // Only proceed if there are valid schedules
            if !scheduleIds.isEmpty {
                Task {
                    await self.updateBookmarks(scheduleIds: scheduleIds)
                }
            }
        }
    }


    /// Toggles the onboarding preference parameter
    func finishOnboarding() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.preferenceService.setUserOnboarded()
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
    ) async {
        let scheduleRequiresAuth = existingSchedule.requiresAuth
        let scheduleTitle = await getScheduleTitle(for: existingSchedule, schoolId: schoolId)
        let realmSchedule: Schedule = schedule.toRealmSchedule(
            scheduleRequiresAuth: scheduleRequiresAuth,
            schoolId: schoolId,
            existingCourseColors: self.realmManager.getCourseColors(),
            scheduleTitle: scheduleTitle
        )
        self.realmManager.updateSchedule(scheduleId: schedule.id, newSchedule: realmSchedule)
    }
    
    /// Gets human readable title for Schedule
    @MainActor private func getScheduleTitle(for schedule: Schedule, schoolId: String) async -> String {
        let scheduleId = schedule.scheduleId
            .replacingOccurrences(of: "p.", with: "")
            .replacingOccurrences(of: "k.", with: "")
        
        do {
            let endpoint: Endpoint = .searchProgramme(searchQuery: scheduleId, schoolId: schoolId)
            let searchResult: Response.Search = try await self.kronoxManager.get(endpoint)
            
            return searchResult.items.first?.subtitle ?? ""
        } catch {
            return ""
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        cancellables.forEach { $0.cancel() }
    }

}
