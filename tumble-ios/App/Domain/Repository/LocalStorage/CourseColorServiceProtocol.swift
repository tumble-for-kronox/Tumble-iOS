//
//  CourseColorRepository.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation
import SwiftUI

protocol CourseColorServiceProtocol {
    
    func load(completion: @escaping (Result<CourseAndColorDict, AppError>)->Void)
    
    func save(coursesAndColors: [String : String], completion: @escaping (Result<Int, AppError>)->Void)
    
    func removeAll(completion: @escaping (Result<Int, AppError>) -> Void)
    
    func remove(removeCourses: [String], completion: @escaping (Result<Int, AppError>)->Void)
}
