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

    func load(completion: @escaping (Result<[Response.Schedule], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([]))
                        }
                        return
                    }
                let schedules = try JSONDecoder().decode([Response.Schedule].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(schedules))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error as! Error))
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
                            var newSchedules = schedules
                            newSchedules.append(schedule)
                            
                            let data = try JSONEncoder().encode(newSchedules)
                            try data.write(to: fileURL)
                            DispatchQueue.main.async {
                                AppLogger.shared.info("Successfully saved schedule \(schedule.id)")
                                completion(.success(1))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                AppLogger.shared.info("Failed to save \(schedule.id)")
                                completion(.failure(error as! Error))
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error as! Error))
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
                var schedules = try JSONDecoder().decode([Response.Schedule].self, from: file.availableData)
                schedules.removeAll()
                let data = try JSONEncoder().encode(schedules)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    AppLogger.shared.info("Removed all schedules")
                    completion(.success(schedules.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error as! Error))
                    }
            }
        }
    }
    
    func remove(schedule: Response.Schedule, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var schedules = try JSONDecoder().decode([Response.Schedule].self, from: file.availableData)
                
                
                schedules.removeAll(where: {$0.id == schedule.id})
                
                let data = try JSONEncoder().encode(schedules)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    AppLogger.shared.info("Removed schedule \(schedule.id)")
                    completion(.success(schedules.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error as! Error))
                    }
                }
        }
    }
}

