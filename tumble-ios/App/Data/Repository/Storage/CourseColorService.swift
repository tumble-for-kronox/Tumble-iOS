//
//  ColorStore.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/29/22.
//

import Foundation
import SwiftUI

typealias CourseAndColorDict = [String : String]

class CourseColorService: ObservableObject, CourseColorServiceProtocol {
    
    private func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
           in: .userDomainMask,
           appropriateFor: nil,
           create: false)
            .appendingPathComponent("colors.data")
    }

    func replace(for event: Response.Event, with color: Color, completion: @escaping (Result<Int, Error>) -> Void) -> Void {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                self.load { result in
                    switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    case .success(let courses):
                        do {
                            var newCourses = courses
                            newCourses[event.course.id] = color.toHex()
                            let data = try JSONEncoder.shared.encode(newCourses)
                            try data.write(to: fileURL)
                            DispatchQueue.main.async {
                                completion(.success(1))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(.internal(reason: error.localizedDescription)))
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                }
            }
        }
    }
    
    func load(completion: @escaping (Result<CourseAndColorDict, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([:]))
                        }
                        return
                    }
                let courses = try JSONDecoder.shared.decode(CourseAndColorDict.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(courses))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
            }
    }
    

    func save(coursesAndColors: [String : String], completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                self.load { result in
                    switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    case .success(let courses):
                        do {

                            let finalCourseColorDict = courses.merging(coursesAndColors) { (_, new) in new }
                            let data = try JSONEncoder.shared.encode(finalCourseColorDict)
                            try data.write(to: fileURL)
                            DispatchQueue.main.async {
                                completion(.success(1))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(.internal(reason: error.localizedDescription)))
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
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
                var courses = try JSONDecoder.shared.decode(CourseAndColorDict.self, from: file.availableData)
                
                courses.removeAll()
                
                let data = try JSONEncoder.shared.encode(courses)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    completion(.success(courses.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
        }
    }
    
    func remove(removeCourses: [String], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var courses = try JSONDecoder.shared.decode(CourseAndColorDict.self, from: file.availableData)
                
                for courseId in removeCourses {
                    courses.removeValue(forKey: courseId)
                }
                
                let data = try JSONEncoder.shared.encode(courses)
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    completion(.success(courses.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.internal(reason: error.localizedDescription)))
                    }
                }
        }
    }
}
