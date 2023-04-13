//
//  ScheduleStoreModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation

struct ScheduleData: Codable, Hashable {
    static func == (lhs: ScheduleData, rhs: ScheduleData) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id, cachedAt: String
    let days: [Response.Day]
    let lastUpdated: Date
}
