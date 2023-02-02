//
//  DayUIModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/19/22.
//

import Foundation

struct DayUiModel: Identifiable, Hashable {
    let id: UUID = UUID()
    let name, date: String
    let isoString: String
    let weekNumber: Int
    var events: [Response.Event]
}
