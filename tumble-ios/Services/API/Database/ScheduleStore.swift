//
//  DBClient.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/24/22.
//

import Foundation

class ScheduleStore: ObservableObject {
    private static func fileURL() throws -> URL {
            try FileManager.default.url(for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false)
                .appendingPathComponent("schedules.data")
        }

    static func load(completion: @escaping (Result<[API.Types.Response.Schedule], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([]))
                        }
                        return
                    }
                let schedules = try JSONDecoder().decode([API.Types.Response.Schedule].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(schedules))
                }
            } catch {
                DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
    }

    static func save(schedule: API.Types.Response.Schedule, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                load { result in
                    switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            print("failed to save \(schedule.id)")
                            completion(.failure(error))
                        }
                    case .success(let schedules):
                        do {
                            var newSchedules = schedules
                            newSchedules.append(schedule)
                            
                            let data = try JSONEncoder().encode(newSchedules)
                            try data.write(to: fileURL)
                            DispatchQueue.main.async {
                                print("Saved schedule \(schedule.id)")
                                completion(.success(1))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                print("Failed to save schedule \(schedule.id)")
                                completion(.failure(error))
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func remove(schedule: API.Types.Response.Schedule, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var schedules = try JSONDecoder().decode([API.Types.Response.Schedule].self, from: file.availableData)
                
                
                schedules.removeAll(where: {$0.id == schedule.id})
                
                let data = try JSONEncoder().encode(schedules)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    print("Removed schedule \(schedule.id)")
                    completion(.success(schedules.count))
                }
            } catch {
                DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
        }
    }
}

