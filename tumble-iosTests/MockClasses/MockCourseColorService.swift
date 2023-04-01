//
//  MockCourseColorService.swift
//  tumble-iosTests
//
//  Created by Adis Veletanlic on 4/1/23.
//

import SwiftUI
import Foundation
@testable import tumble_ios

/// Mock class for CourseColorService
class MockCourseColorService: CourseColorService {
    
    var saveCalled = false
    var removeCalled = false
    var loadCalled = false
    var removeAllCalled = false
    
    var mockCourseColorDict: [String: String] = [:]
    
    override func replace(for event: Response.Event, with color: Color, completion: @escaping (Result<Int, Error>) -> Void) {}
    
    override func load(completion: @escaping (Result<CourseAndColorDict, Error>) -> Void) {}
    
    override func save(coursesAndColors: [String : String], completion: @escaping (Result<Int, Error>) -> Void) {}
    
    override func removeAll(completion: @escaping (Result<Int, Error>) -> Void) {}
    
    override func remove(removeCourses: [String], completion: @escaping (Result<Int, Error>)->Void) {}
    
}
