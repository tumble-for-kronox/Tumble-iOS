//
//  Utilities.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import Foundation
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


func getTimeOfDay() -> String {
    let date = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)

    switch hour {
    case 0...11:
        return "morning"
    case 12...18:
        return "afternoon"
    default:
        return "evening"
    }
}
