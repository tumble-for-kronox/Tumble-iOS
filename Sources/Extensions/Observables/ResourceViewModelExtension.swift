//
//  ResourceViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension ResourceViewModel {
    func cancelDataTaskIfDateChanged(dataTask: URLSessionDataTask?, date: Date) {
        let currentSelectedDate = date
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1)) {
            if self.selectedPickerDate != currentSelectedDate {
                DispatchQueue.main.async {
                    // Selected date has changed, cancel the dataTask
                    AppLogger.shared.critical("Cancelling task due to date change")
                    dataTask?.cancel()
                }
            }
        }
    }
}
