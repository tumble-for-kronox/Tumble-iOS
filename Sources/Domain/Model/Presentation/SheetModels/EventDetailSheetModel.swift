//
//  EventDetailSheetModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

struct ExamDetailSheetModel: Identifiable {
    var id: UUID = UUID()
    let event: Response.AvailableKronoxUserEvent
}
