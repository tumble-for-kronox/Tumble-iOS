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

extension ScheduleMainPageView {
    @MainActor class ScheduleMainPageViewModel: ObservableObject {
        @Published var scheduleViewTypes: [ScheduleViewType] = ScheduleViewType.allValues
        @Published var viewType: ScheduleViewType = {
            var hasView: Bool = UserDefaults.standard.isKeyPresentInUserDefaults(key: UserDefaults.StoreKey.viewType.rawValue)
            if !(hasView) {
                UserDefaults.standard.setViewType(viewType: 0)
                return ScheduleViewType.allValues[0]
            }
            
            var viewType: Int = UserDefaults.standard.getDefault(key: UserDefaults.StoreKey.viewType.rawValue) as! Int
            return ScheduleViewType.allValues[viewType]
        }()
        private var userDefaults = UserDefaults.standard
        
        func onChangeViewType(viewType: ScheduleViewType) -> Void {
            let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
            userDefaults.setViewType(viewType: viewTypeIndex)
        }
    }
}
