//
//  BookmarksViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Combine
import RealmSwift
import SwiftUI

struct BookmarkData {
    let days: [Day]
    let calendarEventsByDate: [Date : [Event]]
    let weeks: [Int : [Day]]
}

final class BookmarksViewModel: ObservableObject {
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    let scheduleViewTypes: [ViewType] = ViewType.allCases
    
    @Inject var preferenceService: PreferenceService
    @Inject var schoolManager: SchoolManager
    @Inject var realmManager: RealmManager
    
    @Published var defaultViewType: ViewType = .list
    @Published var eventSheet: EventDetailsSheetModel? = nil
    @Published var status: BookmarksViewStatus = .loading
    @Published var bookmarkData: BookmarkData = BookmarkData(days: [], calendarEventsByDate: [:], weeks: [:])
    
    private var schedulesToken: NotificationToken? = nil
    private var workItem: DispatchWorkItem?
    
    init() {
        defaultViewType = preferenceService.getDefaultViewType()
        setupRealmListener()
    }

    private func setupRealmListener() {
        let schedules = realmManager.getAllLiveSchedules()
        schedulesToken = schedules.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let results), .update(let results, _, _, _):
                self.workItem?.cancel()
                self.workItem = DispatchWorkItem { [weak self] in
                    self?.createDaysAndCalendarEvents(schedules: Array(results))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: self.workItem!)
            case .error:
                DispatchQueue.main.async {
                    self.status = .error
                }
            }
        }
    }

    
    /// Instantiates viewmodel for viewing a specific `Event` object
    func createViewModelEventSheet(event: Event) -> EventDetailsSheetViewModel {
        return viewModelFactory.makeViewModelEventDetailsSheet(event: event)
    }
    
    /// Whenever the user changes the bookmark viewtype `[.list, .calendar, .week]`,
    /// this function stores it in `UserDefaults` and updates the local state
    func onChangeViewType(viewType: ViewType) {
        let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
        preferenceService.setViewType(viewType: viewTypeIndex)
        defaultViewType = viewType
    }
    
    /// Creates any calendar and list events, parsing through the schedules that
    /// should not be visible or any schedules that have missing events
    func createDaysAndCalendarEvents(schedules: [Schedule]) {
        
        DispatchQueue.main.async { [weak self] in
            self?.status = .loading
            AppLogger.shared.info("Running function ...")
        }
        
        let hiddenScheduleIds = schedules.filter { !$0.toggled }.map { $0.scheduleId }
        
        let visibleSchedules = schedules.filter { $0.toggled }.map { $0 }
        
        /// If user has not saved any schedules
        if schedules.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.status = .uninitialized
            }
            return
        }
        
        if allSchedulesHidden(schedules: schedules) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.status = .hiddenAll
            }
            return
        }
        
        /// If the visible schedules do not contain anything
        if visibleSchedules.allSatisfy({ $0.isMissingEvents() }) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.status = .empty
            }
            return
        }
        
        let days = filterHiddenBookmarks(
            schedules: Array(schedules),
            hiddenBookmarks: hiddenScheduleIds
        )
        .flattenAndMerge()
        .ordered()
        .filterEmptyDays()
        .filterValidDays()
        
        let calendarEvents = makeCalendarEvents(days: days)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            AppLogger.shared.debug("Updating days ..", file: "BookmarksViewModel")
            self.bookmarkData = BookmarkData(days: days, calendarEventsByDate: calendarEvents, weeks: days.groupedByWeeks())
            self.status = .loaded
        }
    }
    
    /// Checks if all schedules the user has bookmarked are toggled as `False`
    private func allSchedulesHidden(schedules: [Schedule]) -> Bool {
        return schedules.filter({ $0.toggled }).isEmpty
    }
    
    /// Creates events for the `.calendar` viewtype
    private func makeCalendarEvents(days: [Day]) -> [Date: [Event]] {
        var dict = [Date: [Event]]()
        for day in days {
            for event in day.events {
                if let date = dateFormatterEvent.date(from: event.from) {
                    let normalizedDate = Calendar.current.startOfDay(for: date)
                    if dict[normalizedDate] == nil {
                        dict[normalizedDate] = [event]
                    } else {
                        dict[normalizedDate]?.append(event)
                    }
                }
            }
        }
        return dict
    }
}
