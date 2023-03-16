//
//  ScheduleStoreModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation

struct ScheduleStoreModel: Codable, Hashable {
    static func == (lhs: ScheduleStoreModel, rhs: ScheduleStoreModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id, cachedAt: String
    let days: [Response.Day]
    let lastUpdated: Date
}
