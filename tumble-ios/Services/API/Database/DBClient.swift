//
//  DBClient.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/24/22.
//

import Foundation
import SQLite3

extension Database {
    class Client {
        static let shared = Client()
        var db: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? nil
                
        func saveSchedule(schedule: API.Types.Response.Schedule) -> Void {
            do {
                let url = db?.appendingPathComponent(schedule.id)
                if url != nil {
                    let data = try JSONEncoder().encode(schedule)
                    try data.write(to: url!, options: [.atomic, .completeFileProtection])
                    let input = try String(contentsOf: url!)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        func removeSchedule(scheduleId: String) -> Void {
            
        }
    }
}
