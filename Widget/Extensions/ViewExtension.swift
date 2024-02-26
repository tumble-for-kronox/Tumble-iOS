//
//  ViewExtension.swift
//  WidgetExtension
//
//  Created by Adis Veletanlic on 2/26/24.
//

import Foundation
import SwiftUI

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
