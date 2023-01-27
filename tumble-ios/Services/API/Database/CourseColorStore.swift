//
//  ColorStore.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/29/22.
//

import Foundation
import SwiftUI

typealias CourseAndColorDict = [String : String]

class CourseColorStore: ObservableObject {
    private static func fileURL() throws -> URL {
            try FileManager.default.url(for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false)
                .appendingPathComponent("colors.data")
        }

    static func load(completion: @escaping (Result<CourseAndColorDict, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([:]))
                        }
                        return
                    }
                let courses = try JSONDecoder().decode(CourseAndColorDict.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(courses))
                }
            } catch {
                DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    // [String : [String : Color]] is a dictionary of
    // course names with its respective dictionary of hexColor: String, and color: Color
    // {
    //      "course_one" : {
    //                      "#45F327" : Color.blue
    //                     }
    // }
    static func save(coursesAndColors: [String : [String : Color]], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                load { result in
                    switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    case .success(let courses):
                        do {
                            var newCourseColorsDict: CourseAndColorDict = [:]
                            for (course, colorDict) in coursesAndColors {
                                for (hexColor, _) in colorDict {
                                    newCourseColorsDict[course] = hexColor;
                                }
                            }

                            let finalCourseColorDict = courses.merging(newCourseColorsDict) { (_, new) in new }
                            let data = try JSONEncoder().encode(finalCourseColorDict)
                            try data.write(to: fileURL)
                            DispatchQueue.main.async {
                                completion(.success(1))
                            }
                        } catch {
                            DispatchQueue.main.async {
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
    
    static func removeAll(completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var courses = try JSONDecoder().decode(CourseAndColorDict.self, from: file.availableData)
                
                courses.removeAll()
                
                let data = try JSONEncoder().encode(courses)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    completion(.success(courses.count))
                }
            } catch {
                DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
        }
    }
    
    static func remove(removeCourses: [String], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var courses = try JSONDecoder().decode(CourseAndColorDict.self, from: file.availableData)
                
                for courseId in removeCourses {
                    courses.removeValue(forKey: courseId)
                }
                
                let data = try JSONEncoder().encode(courses)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    completion(.success(courses.count))
                }
            } catch {
                DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
        }
    }
}
