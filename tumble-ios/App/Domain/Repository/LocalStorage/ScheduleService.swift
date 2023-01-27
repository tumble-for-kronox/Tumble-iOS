//
//  ScheduleRepository.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

protocol ScheduleService {
    
    func load(completion: @escaping (Result<[Response.Schedule], Error>)->Void)

    func save(schedule: Response.Schedule, completion: @escaping (Result<Int, Error>)->Void)
    
    func removeAll(completion: @escaping (Result<Int, Error>) -> Void)
    
    func remove(schedule: Response.Schedule, completion: @escaping (Result<Int, Error>)->Void)
}
