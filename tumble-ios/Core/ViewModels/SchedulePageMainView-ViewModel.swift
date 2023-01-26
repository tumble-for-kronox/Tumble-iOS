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
    @MainActor class ScheduleMainPageViewModel: ObservableObject {
        @Published var scheduleViewTypes: [ScheduleViewType] = ScheduleViewType.allValues
        @Published var status: ScheduleMainPageStatus = .loading
        @Published var schedules: [API.Types.Response.Schedule] = []
        @Published var days: [DayUiModel] = []
        @Published var courseColors: [String : String] = [:]
        @Published var viewType: ScheduleViewType = {
            let hasView: Bool = UserDefaults.standard.isKeyPresentInUserDefaults(key: UserDefaults.StoreKey.viewType.rawValue)
            if !(hasView) {
                UserDefaults.standard.setViewType(viewType: 0)
                return ScheduleViewType.allValues[0]
            }
            
            let viewType: Int = UserDefaults.standard.getDefault(key: UserDefaults.StoreKey.viewType.rawValue) as! Int
            return ScheduleViewType.allValues[viewType]
        }()
        private var store: ScheduleStore = ScheduleStore()
        private var userDefaults = UserDefaults.standard
        
        init() {
            self.initSchedules()
        }
        
        private func initSchedules() -> Void {
            ScheduleStore.load { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(_):
                        self.status =  .error
                    case .success(let schedules):
                        if !schedules.isEmpty {
                            let days: [DayUiModel] = schedules.removeDuplicateEvents().flatten()
                            self.days = days
                            self.status = .loaded
                            self.initCourseColors()
                        }
                        else {
                            self.status = .uninitialized
                        }
                    }
                }
            }
        }
        
        private func initCourseColors() -> Void {
            for day in self.days {
                for event in day.events {
                    CourseColorStore.load { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .failure(_):
                                print("Error on course with id: \(event.course.id)")
                            case .success(let courses):
                                if !courses.isEmpty {
                                    self.courseColors = courses
                                }
                            }
                        }
                    }
                }
            }
        }
        
        func onChangeViewType(viewType: ScheduleViewType) -> Void {
            let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
            userDefaults.setViewType(viewType: viewTypeIndex)
        }
    }
}
