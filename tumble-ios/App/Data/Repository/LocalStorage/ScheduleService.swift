//
//  DBClient.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/24/22.
//

import Foundation

class ScheduleService: ObservableObject, ScheduleServiceProtocol {
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
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([]))
                        }
                        return
                    }
                let schedules = try JSONDecoder().decode([ScheduleStoreModel].self, from: file.availableData)
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

    func save(schedule: Response.Schedule, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                self.load { result in
                    switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            AppLogger.shared.info("Failed to save \(schedule.id)")
                            completion(.failure(error))
                        }
                    case .success(let schedules):
                        do {
                            
                            let newSchedules = self.insertOrReplace(for: schedule, with: schedules)
                            
                            let data = try JSONEncoder().encode(newSchedules)
                            try data.write(to: fileURL)
                            DispatchQueue.main.async {
                                AppLogger.shared.info("Successfully saved schedule \(schedule.id)")
                                completion(.success(1))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                AppLogger.shared.info("Failed to save \(schedule.id)")
                                completion(.failure(.internal(reason: error.localizedDescription)))
                            }
                        }
                    }
                }
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
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(1))
                    }
                    return
                }
                var schedules = try JSONDecoder().decode([ScheduleStoreModel].self, from: file.availableData)
                schedules.removeAll()
                let data = try JSONEncoder().encode(schedules)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    AppLogger.shared.info("Removed all schedules")
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
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var schedules = try JSONDecoder().decode([ScheduleStoreModel].self, from: file.availableData)
                
                schedules.removeAll(where: {$0.id == scheduleId})
                
                let data = try JSONEncoder().encode(schedules)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    AppLogger.shared.info("Removed schedule \(scheduleId)")
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
    
}
