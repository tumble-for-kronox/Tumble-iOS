//
//  Color.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/29/22.
//

import Foundation
import SwiftUI

func hexStringToUIColor (hex:String) -> Color {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return Color.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return Color(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0
    )
}

func assignCardColor(event: API.Types.Response.Event) -> String {
    var cardColor: String = ""
    let group = DispatchGroup()
    group.enter()
    CourseColorStore.load { result in
        DispatchQueue.main.async {
            switch result {
            case .failure(_):
                print("Error on course with id: \(event.course.id)")
            case .success(let courses):
                if !courses.isEmpty {
                    let hexColor = courses[event.course.id]!;
                    cardColor = hexColor == "" ? colors.randomElement() ?? "FFFFFF" : hexColor
                }
            }
        }
        group.leave()
    }
    group.wait()
    return cardColor
}
