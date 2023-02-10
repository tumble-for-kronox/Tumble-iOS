//
//  CourseColorRepository.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation
import SwiftUI

protocol CourseColorServiceProtocol {
    
    func load(completion: @escaping (Result<CourseAndColorDict, Error>)->Void)
    
    func save(coursesAndColors: [String : String], completion: @escaping (Result<Int, Error>)->Void)
    
    func replace(for event: Response.Event, with color: Color, completion: @escaping (Result<Int, Error>)->Void) -> Void
    
    func removeAll(completion: @escaping (Result<Int, Error>) -> Void)
    
    func remove(removeCourses: [String], completion: @escaping (Result<Int, Error>)->Void)
}
