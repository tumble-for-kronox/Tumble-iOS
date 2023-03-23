//
//  TextFieldExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation
import SwiftUI

extension TextField {
    func searchBoxText() -> some View {
        self.font(.system(size: 18, weight: .semibold))
        .padding(.leading, 5)
        .disableAutocorrection(true)
    }
}
