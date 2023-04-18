//
//  Schedule.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-17.
//

import Foundation
import RealmSwift

class Schedule: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var scheduleId: String
    @Persisted var cachedAt: String
    @Persisted var days: List<Day>
    
    convenience init(
        scheduleId: String,
        cachedAt: String,
        days: RealmSwift.List<Day>
    ) {
        self.init()
        self.scheduleId = scheduleId
        self.cachedAt = cachedAt
        self.days = days
    }
    
}
