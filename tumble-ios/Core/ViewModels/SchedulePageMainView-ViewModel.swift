//
//  SchedulePageMainView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Foundation

enum ScheduleViewType: String {
    case list = "List"
    case week = "Week"
    case calendar = "Calendar"
    
    static let allValues: [ScheduleViewType] = [list, week, calendar]
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
                switch result {
                case .failure(_):
                    self.status =  .error
                case .success(let schedules):
                    if !schedules.isEmpty {
                        let days: [DayUiModel] = schedules.flatten()
                        self.days = days
                        self.status = .loaded
                    }
                    else {
                        self.status = .uninitialized
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
