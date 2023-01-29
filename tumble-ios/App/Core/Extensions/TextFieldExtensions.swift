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
        self.font(.custom("Montserrat-Regular", size: 18))
        .padding(.leading, 5)
        .disableAutocorrection(true)
    }
}
