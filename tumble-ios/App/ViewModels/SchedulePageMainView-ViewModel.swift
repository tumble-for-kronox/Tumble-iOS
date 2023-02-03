//
//  SchedulePageMainView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Foundation
import SwiftUI

enum ScheduleViewType: String {
    case list = "List"
    case calendar = "Calendar"
    
    static let allValues: [ScheduleViewType] = [list, calendar]
}

enum ScheduleMainPageStatus {
    case loading
    case loaded
    case uninitialized
    case error
}

extension ScheduleMainPageView {
    @MainActor final class ScheduleMainPageViewModel: ObservableObject {
        
        @Inject var scheduleService: ScheduleService
        @Inject var preferenceService: PreferenceService
        @Inject var courseColorService: CourseColorService
        
        @Published var scheduleViewTypes: [ScheduleViewType] = ScheduleViewType.allValues
        @Published var status: ScheduleMainPageStatus = .loading
        @Published var days: [DayUiModel] = []
        @Published var courseColors: CourseAndColorDict = [:]
        @Published var defaultViewType: ScheduleViewType
        
        init () {
            self.defaultViewType = .list
            self.loadSchedules()
            self.defaultViewType = preferenceService.getDefaultViewType()
        }
        
        func loadSchedules() -> Void {
            scheduleService.load { result in
                switch result {
                case .failure(_):
                    self.status =  .error
                case .success(let schedules):
                    if !schedules.isEmpty {
                        let days: [DayUiModel] = schedules.removeDuplicateEvents().flatten()
                        self.days = days
                        self.status = .loaded
                        self.loadCourseColors()
                    }
                    else {
                        self.status = .uninitialized
                    }
                }
            }
        }
        
        func onChangeViewType(viewType: ScheduleViewType) -> Void {
            let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
            preferenceService.setViewType(viewType: viewTypeIndex)
        }
        
        fileprivate func loadCourseColors() -> Void {
            courseColorService.load { result in
                switch result {
                case .failure(_):
                    // TODO: Add user notification toast that something went wrong
                    AppLogger.shared.info("Could not load course colors")
                case .success(let courses):
                    if !courses.isEmpty {
                        self.courseColors = courses
                    }
                }
            }
        }
    }
}
