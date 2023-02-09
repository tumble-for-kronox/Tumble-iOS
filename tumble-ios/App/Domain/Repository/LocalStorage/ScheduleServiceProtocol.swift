//
//  ScheduleRepository.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

protocol ScheduleServiceProtocol {
    
    func load(completion: @escaping (Result<[ScheduleStoreModel], Error>) -> Void)
    
    func save(schedule: Response.Schedule, completion: @escaping (Result<Int, Error>) -> Void)
    
    func removeAll(completion: @escaping (Result<Int, Error>) -> Void)
    
    func remove(scheduleId: String, completion: @escaping (Result<Int, Error>) -> Void)
}
