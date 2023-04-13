//
//  ParentViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension ParentViewModel {
    
    func removeAllCourseColors(completion: @escaping () -> Void) -> Void {
        self.courseColorService.removeAll { result in
            switch result {
            case .failure(let failure):
                // TODO: Add error message for user
                AppLogger.shared.critical("Could not remove course colors: \(failure)")
            case .success:
                // TODO: Add success message for user
                AppLogger.shared.debug("Removed all course colors from local storage")
                completion()
            }
        }
    }
    
    
    func removeAllSchedules(completion: @escaping () -> Void) -> Void {
        scheduleService.removeAll { result in
            switch result {
            case .failure(let failure):
                // TODO: Add error message for user
                AppLogger.shared.critical("Could not remove schedules: \(failure)")
            case .success:
                // TODO: Add success message for user
                AppLogger.shared.debug("Removed all schedules from local storage")
                completion()
            }
        }
    }
    
    func cancelAllNotifications(completion: @escaping () -> Void) -> Void {
        notificationManager.cancelNotifications()
        completion()
    }
}
