//
//  BookmarksViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Combine
import Foundation
import RealmSwift
import SwiftUI

final class BookmarksViewModel: ObservableObject {
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    let scheduleViewTypes: [BookmarksViewType] = BookmarksViewType.allValues
    
    @Inject var preferenceService: PreferenceService
    @Inject var schoolManager: SchoolManager
    @Inject var realmManager: RealmManager
    
    @Published var defaultViewType: BookmarksViewType = .list
    @Published var eventSheet: EventDetailsSheetModel? = nil
    @Published var days: [Day] = .init()
    @Published var status: BookmarksViewStatus = .loading
    @Published var calendarEventsByDate: [Date : [Event]] = [:]
    
    var schedulesToken: NotificationToken? = nil
    
    init() {
        defaultViewType = preferenceService.getDefaultViewType()
        // Observe changes to schedules and update days
        let schedules = realmManager.getAllLiveSchedules()
        schedulesToken = schedules.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let results), .update(let results, _, _, _):
                self.createDaysAndCalendarEvents(schedules: Array(results))
            case .error:
                DispatchQueue.main.async {
                    self.status = .error
                }
            }
        }
    }
    
    func createViewModelEventSheet(event: Event) -> EventDetailsSheetViewModel {
        return viewModelFactory.makeViewModelEventDetailsSheet(event: event)
    }
    
    func onChangeViewType(viewType: BookmarksViewType) {
        let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
        preferenceService.setViewType(viewType: viewTypeIndex)
        defaultViewType = viewType
    }
    
    func createDaysAndCalendarEvents(schedules: [Schedule]) {
        
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            AppLogger.shared.debug("Updating days ..", file: "BookmarksViewModel")
            self.days = days
            self.calendarEventsByDate = self.makeCalendarEvents(days: days)
            self.status = .loaded
        }
    }
    
    private func allSchedulesHidden(schedules: [Schedule]) -> Bool {
        return schedules.filter({ $0.toggled }).isEmpty
    }
    
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
