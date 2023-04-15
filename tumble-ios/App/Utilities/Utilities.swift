//
//  Utilities.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import Foundation
import UIKit
import SwiftUI

func navigationBarFont() -> UIFont {
    var titleFont = UIFont.preferredFont(forTextStyle: .headline) 
            titleFont = UIFont(
                descriptor:
                    titleFont.fontDescriptor
                    .withSymbolicTraits(.traitBold)
                    ??
                    titleFont.fontDescriptor,
                size: titleFont.pointSize
            )
    return titleFont
}

func scheduleNeedsUpdate(schedule: ScheduleData) -> Bool {
    let calendar = Calendar(identifier: .gregorian)
    let currentDate = Date()
    let difference = calendar.dateComponents(
        [.day, .hour, .minute, .second],
        from: schedule.lastUpdated,
        to: currentDate)
    if let hours = difference.hour {
        AppLogger.shared.debug("Time in hours since last update for schedule with id \(schedule.id) -> \(hours)")
        return hours >= 2
    }
    return true
}

func filterHiddenBookmarks(schedules: [ScheduleData], hiddenBookmarks: [String]) -> [ScheduleData] {
    return schedules.filter { schedule in
        !hiddenBookmarks.contains { $0 == schedule.id }
    }
}

func getCurrentDate(truncate: Bool = false) -> String {
    let currentDate = Date()
    if truncate {
        dateFormatterLong.dateStyle = .medium
    }
    dateFormatterLong.timeStyle = .none
    let dateString = dateFormatterLong.string(from: currentDate)
    return dateString
}

func getThemeColorScheme(appearance: String) -> ColorScheme {
    switch appearance {
    case AppearanceTypes.dark.rawValue:
        return .dark
    case AppearanceTypes.light.rawValue:
        return .light
    default:
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .dark
        } else {
            return .light
        }
    }
}
