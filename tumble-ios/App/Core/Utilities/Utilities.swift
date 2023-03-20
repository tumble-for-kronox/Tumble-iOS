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


func getCurrentDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    let currentDate = Date()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    let dateString = dateFormatter.string(from: currentDate)
    return dateString
}
