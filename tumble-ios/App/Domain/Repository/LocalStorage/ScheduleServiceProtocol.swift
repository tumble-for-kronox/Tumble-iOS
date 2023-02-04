//
//  ScheduleRepository.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

protocol ScheduleServiceProtocol {
    
    func load(completion: @escaping (Result<[Response.Schedule], NetworkError>)->Void)

    func save(schedule: Response.Schedule, completion: @escaping (Result<Int, NetworkError>)->Void)
    
    func removeAll(completion: @escaping (Result<Int, NetworkError>) -> Void)
    
    func remove(schedule: Response.Schedule, completion: @escaping (Result<Int, NetworkError>)->Void)
}
