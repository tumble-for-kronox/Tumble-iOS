//
//  WeekEventCardModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 4/7/23.
//

import Foundation

struct DayEventCardModel: Identifiable {
    var id: UUID = .init()
    var offset: CGFloat = 0
    var event: Event
}
