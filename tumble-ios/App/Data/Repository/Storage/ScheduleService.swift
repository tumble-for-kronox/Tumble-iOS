//
//  DBClient.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/24/22.
//

import Foundation

class ScheduleService: ObservableObject, ScheduleServiceProtocol {
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    
    private func fileURL() throws -> URL {
            try FileManager.default.url(for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false)
                .appendingPathComponent("schedules.data")
        }
    
    
    func load(completion: @escaping (Result<[ScheduleStoreModel], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                let decoder = JSONDecoder()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([]))
                        }
                        return
                    }
                let schedules = try decoder.decode([ScheduleStoreModel].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(schedules))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: "Could not decode schedules stored locally")))
                    }
                }
            }
    }
    
    func load(
        forCurrentWeek completion: @escaping ((Result<[Response.Event], Error>) -> Void),
        hiddenBookmarks: [String]
    ) {
        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)
        let daysUntilFriday = (6 - currentWeekday + 7) % 7
        guard let weekStartDate = calendar.date(byAdding: .day, value: daysUntilFriday, to: now) else {
            completion(.failure(.internal(reason: "Could not calculate week start date")))
            AppLogger.shared.critical("Could not calculate week start date")
            return
        }
        let weekEndDate = calendar.date(byAdding: .day, value: 7, to: weekStartDate)!
        let weekDateRange = weekStartDate...weekEndDate
        AppLogger.shared.debug("Date range: \(weekDateRange)", source: "ScheduleService")
        load(forWeeksInRange: weekDateRange, hiddenBookmarks: hiddenBookmarks) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let events):
                completion(.success(events))
            }
        }
    }

    
    func load(with id: String, completion: @escaping (Result<ScheduleStoreModel, Error>) -> Void) -> Void {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                let decoder = JSONDecoder()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: "Could not load file handle")))
                    }
                    return
                }
                let schedules = try decoder.decode([ScheduleStoreModel].self, from: file.availableData)
                if let schedule = schedules.first(where: { $0.id == id }) {
                    DispatchQueue.main.async {
                        completion(.success(schedule))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: "No schedule with specified id found")))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: "Could not decode schedules stored locally")))
                }
            }
        }
    }


    func save(schedule: Response.Schedule, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                let encoder = JSONEncoder()
                self.load(completion: { (result: Result<[ScheduleStoreModel], Error>) in
                    switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            AppLogger.shared.critical("Failed to save \(schedule.id)")
                            completion(.failure(error))
                        }
                    case .success(let schedules):
                        do {
                            
                            let newSchedules = self.insertOrReplace(for: schedule, with: schedules)
                            
                            let data = try encoder.encode(newSchedules)
                            try data.write(to: fileURL)
                            DispatchQueue.main.async {
                                AppLogger.shared.debug("Successfully saved schedule \(schedule.id)")
                                completion(.success(1))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                AppLogger.shared.critical("Failed to save \(schedule.id)")
                                completion(.failure(.internal(reason: error.localizedDescription)))
                            }
                        }
                    }
                })
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                }
            }
        }
    }
    
    func removeAll(completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                let decoder = JSONDecoder()
                let encoder = JSONEncoder()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(1))
                    }
                    return
                }
                var schedules = try decoder.decode([ScheduleStoreModel].self, from: file.availableData)
                schedules.removeAll()
                let data = try encoder.encode(schedules)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    AppLogger.shared.debug("Removed all schedules")
                    completion(.success(schedules.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                    }
            }
        }
    }
    
    func remove(scheduleId: String, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                let decoder = JSONDecoder()
                let encoder = JSONEncoder()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var schedules = try decoder.decode([ScheduleStoreModel].self, from: file.availableData)
                
                schedules.removeAll(where: {$0.id == scheduleId})
                
                let data = try encoder.encode(schedules)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    AppLogger.shared.debug("Removed schedule \(scheduleId)")
                    completion(.success(schedules.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
        }
    }
}

extension ScheduleService {
    
    fileprivate func insertOrReplace(for schedule: Response.Schedule, with schedules: [ScheduleStoreModel]) -> [ScheduleStoreModel] {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents(in: calendar.timeZone, from: Date.now).date
        
        var newSchedules: [ScheduleStoreModel] = schedules
        
        if newSchedules.contains(where: { $0.id == schedule.id }) {
            for (index, bookmark) in newSchedules.enumerated() {
                if schedule.id == bookmark.id {
                    newSchedules[index] = ScheduleStoreModel(id: schedule.id, cachedAt: schedule.cachedAt, days: schedule.days, lastUpdated: date!)
                }
            }
        } else {
            newSchedules.append(ScheduleStoreModel(id: schedule.id, cachedAt: schedule.cachedAt, days: schedule.days, lastUpdated: date!))
        }
        return newSchedules
    }

    /// Helper function to retrieve events within a specific date range,
    /// takes into account the users currently hidden bookmarks
    fileprivate func load(
        forWeeksInRange range: ClosedRange<Date>,
        hiddenBookmarks: [String],
        completion: @escaping (Result<[Response.Event], Error>) -> Void) {
            DispatchQueue.global(qos: .background).async {
                do {
                    let fileURL = try self.fileURL()
                    let decoder = JSONDecoder()
                    guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([]))
                        }
                        return
                    }
                    let schedules = try decoder.decode([ScheduleStoreModel].self, from: file.availableData)
                    let events = schedules
                        .filter { !hiddenBookmarks.contains($0.id) }
                        .flatMap { $0.days }
                        .filter {
                            if let eventDate = self.dateFormatter.date(from: $0.isoString) {
                                return range.contains(eventDate)
                            }
                            return false
                        }
                        .flatMap { $0.events }
                    DispatchQueue.main.async {
                        AppLogger.shared.debug("Retrieved events for range \(range)", source: "ScheduleService")
                        completion(.success(events))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: "Could not decode schedules stored locally")))
                    }
                }
            }
    }
}
