//
//  InlineEvent.swift
//  WidgetExtension
//
//  Created by Timur Ramazanov on 21.10.2024.
//

import SwiftUI
import WidgetKit
import RealmSwift

struct InlineEvent: View {
    let event: Event
    var body: some View {
        Label(event.locations.first?.locationId.capitalized ?? NSLocalizedString("Unknown", comment: ""), systemImage: "mappin.and.ellipse")
    }
}
