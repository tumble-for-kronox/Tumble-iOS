//
//  DBClient.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/24/22.
//

import Foundation

enum ExecutionStatus {
    case executing
    case error
    case available
}

class ScheduleService: ObservableObject, ScheduleServiceProtocol {
    
    private let serialQueue = OperationQueue()
    @Published public var schedules: [ScheduleData] = []
    @Published public var executionStatus: ExecutionStatus = .available
    
    init() {
        serialQueue.maxConcurrentOperationCount = 1
        serialQueue.qualityOfService = .background
        load(completion: { _ in })
    }
    
    private func fileURL() throws -> URL {
            try FileManager.default.url(for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false)
                .appendingPathComponent("schedules.data")
        }
    
    func getSchedules() -> [ScheduleData] {
        return schedules
    }
    
    func load(completion: @escaping (Result<[ScheduleData], Error>) -> Void) {
        serialQueue.addOperation { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.executionStatus = .executing
            }
            do {
                let fileURL = try self.fileURL()
                let fileCheckResult = checkFile(at: fileURL)
                switch fileCheckResult {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.executionStatus = .available
                        completion(.failure(error))
                    }
                case .success:
                    let decoder = JSONDecoder()
                    guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            self.executionStatus = .error
                            completion(.failure(.internal(reason: "Could not open document file for reading")))
                        }
                        return
                    }
                    let schedules = try decoder.decode([ScheduleData].self, from: file.availableData)
                    DispatchQueue.main.async {
                        self.schedules = schedules.removeDuplicateEvents()
                        self.executionStatus = .available
                        completion(.success(schedules))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.executionStatus = .error
                    completion(.failure(.internal(reason: "Could not decode schedules stored locally")))
                }
            }
        }
    }


    func save(schedule: Response.Schedule, completion: @escaping (Result<Int, Error>)->Void) {
        serialQueue.addOperation { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.executionStatus = .executing
            }
            do {
                let fileURL = try self.fileURL()
                let encoder = JSONEncoder()
                do {
                    let newSchedules = self.insertOrReplace(for: schedule, with: schedules)
                    let data = try encoder.encode(newSchedules)
                    try data.write(to: fileURL)
                    
                    DispatchQueue.main.async {
                        self.schedules = newSchedules.removeDuplicateEvents()
                        AppLogger.shared.debug("Successfully saved schedule \(schedule.id)")
                        self.executionStatus = .available
                        completion(.success(1))
                    }
                } catch {
                    DispatchQueue.main.async {
                        AppLogger.shared.critical("Failed to save \(schedule.id)")
                        self.executionStatus = .error
                        completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.executionStatus = .error
                    completion(.failure(.internal(reason: error.localizedDescription)))
                }
            }
        }
    }
    
    func removeAll(completion: @escaping (Result<Int, Error>) -> Void) {
        serialQueue.addOperation { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.executionStatus = .executing
            }
            do {
                let fileURL = try self.fileURL()
                let fileCheckResult = checkFile(at: fileURL)
                switch fileCheckResult {
                case .success:
                    let decoder = JSONDecoder()
                    let encoder = JSONEncoder()
                    guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            self.executionStatus = .error
                            completion(.failure(.internal(reason: "Failed to load document directory")))
                        }
                        return
                    }
                    var schedules = try decoder.decode([ScheduleData].self, from: file.availableData)
                    schedules.removeAll()
                    let data = try encoder.encode(schedules)
                    try data.write(to: fileURL)
                    
                    DispatchQueue.main.async {
                        self.schedules = schedules.removeDuplicateEvents()
                        AppLogger.shared.debug("Removed all schedules")
                        self.executionStatus = .available
                        completion(.success(schedules.count))
                    }
                case .failure(let failure):
                    DispatchQueue.main.async {
                        self.executionStatus = .available
                        completion(.failure(failure))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.executionStatus = .error
                    completion(.failure(.internal(reason: error.localizedDescription)))
                }
            }
        }
    }
    
    func remove(scheduleId: String, completion: @escaping (Result<Int, Error>)->Void) {
        serialQueue.addOperation { [weak self] in
            guard let self else { return }
            do {
                let fileURL = try self.fileURL()
                let decoder = JSONDecoder()
                let encoder = JSONEncoder()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            self.executionStatus = .error
                            completion(.failure(.internal(reason: "Failed to open document directory")))
                        }
                        return
                    }
                var schedules = try decoder.decode([ScheduleData].self, from: file.availableData)
                schedules.removeAll(where: {$0.id == scheduleId})
                let data = try encoder.encode(schedules)
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    AppLogger.shared.debug("Removed schedule \(scheduleId)")
                    self.schedules = schedules.removeDuplicateEvents()
                    self.executionStatus = .available
                    completion(.success(schedules.count))
                }
            } catch {
                DispatchQueue.main.async {
                    self.executionStatus = .error
                    completion(.failure(.internal(reason: error.localizedDescription)))
                }
            }
        }
    }
}

extension ScheduleService {
    
    fileprivate func insertOrReplace(
        for schedule: Response.Schedule,
        with schedules: [ScheduleData]) -> [ScheduleData] {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents(in: calendar.timeZone, from: Date.now).date
        var newSchedules: [ScheduleData] = schedules
        if newSchedules.contains(where: { $0.id == schedule.id }) {
            for (index, bookmark) in newSchedules.enumerated() {
                if schedule.id == bookmark.id {
                    newSchedules[index] =
                        ScheduleData(
                            id: schedule.id,
                            cachedAt: schedule.cachedAt,
                            days: schedule.days,
                            lastUpdated: date!
                        )
                }
            }
        } else {
            newSchedules.append(
                ScheduleData(
                    id: schedule.id,
                    cachedAt: schedule.cachedAt,
                    days: schedule.days,
                    lastUpdated: date!
                )
            )
        }
        return newSchedules
    }
    
}
