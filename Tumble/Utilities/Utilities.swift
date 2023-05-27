//
//  Utilities.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import Foundation
import SwiftUI
import UIKit

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

func filterHiddenBookmarks(schedules: [Schedule], hiddenBookmarks: [String]) -> [Schedule] {
    return schedules.filter { schedule in
        !hiddenBookmarks.contains { $0 == schedule.scheduleId }
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
