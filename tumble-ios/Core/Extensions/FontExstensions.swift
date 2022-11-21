//
//  FontExstensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import Foundation
import SwiftUI

extension Font {
    static let mediumFont = Font.custom("roboto_regular", size: Font.TextStyle.subheadline.size, relativeTo: .caption)
    static let mediumSmallFont = Font.custom("roboto_regular", size: Font.TextStyle.footnote.size, relativeTo: .caption)
    static let smallFont = Font.custom("roboto_regular", size: Font.TextStyle.caption.size, relativeTo: .caption)
    static let verySmallFont = Font.custom("roboto_regular", size: Font.TextStyle.caption2.size, relativeTo: .caption)
    static let drawerItemFont = Font.custom("roboto_regular", size: 16, relativeTo: .caption)
}

extension Font.TextStyle {
    var size: CGFloat {
        switch self {
        case .largeTitle: return 60
        case .title: return 48
        case .title2: return 34
        case .title3: return 24
        case .headline, .body: return 18
        case .subheadline, .callout: return 16
        case .footnote: return 14
        case .caption: return 15
        case .caption2: return 18
        @unknown default:
            return 8
        }
    }
}
