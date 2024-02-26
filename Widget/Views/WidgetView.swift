//
//  WidgetView.swift
//  WidgetExtension
//
//  Created by Adis Veletanlic on 2/26/24.
//

import SwiftUI
import RealmSwift
import WidgetKit

struct WidgetView : View {
    @Environment(\.widgetFamily) var family
    let event: Event
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallEvent(event: event)
        case .systemMedium:
            MediumEvent(event: event)
        default:
            Text("Some other WidgetFamily in the future.")
        }
    }
}
