//
//  EventSheetModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation
import SwiftUI

struct EventDetailsSheetModel: Identifiable {
    var id: UUID = UUID()
    let event: Event
}
