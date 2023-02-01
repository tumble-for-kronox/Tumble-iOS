//
//  Utilities.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import Foundation
import UIKit

func navigationBarFont() -> UIFont {
    var titleFont = UIFont.preferredFont(forTextStyle: .headline) /// the default large title font
            titleFont = UIFont(
                descriptor:
                    titleFont.fontDescriptor
                    .withDesign(.rounded)?
                    .withSymbolicTraits(.traitBold)
                    ??
                    titleFont.fontDescriptor,
                size: titleFont.pointSize
            )
    return titleFont
}
