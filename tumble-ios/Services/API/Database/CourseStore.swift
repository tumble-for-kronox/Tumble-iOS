//
//  ColorStore.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/29/22.
//

import Foundation

struct Course: Codable {
    let id: String
    let hexColor: String
}

class CourseStore: ObservableObject {
    private static func fileURL() throws -> URL {
            try FileManager.default.url(for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false)
                .appendingPathComponent("colors.data")
        }

    static func load(completion: @escaping (Result<[Course], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([]))
                        }
                        return
                    }
                let courses = try JSONDecoder().decode([Course].self, from: file.availableData)
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

    static func save(course: Course, completion: @escaping (Result<Int, Error>)->Void) {
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
                            var newCourses = courses
                            newCourses.append(course)
                            
                            let data = try JSONEncoder().encode(newCourses)
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
    
    static func remove(courseId: String, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success(1))
                        }
                        return
                    }
                var courses = try JSONDecoder().decode([Course].self, from: file.availableData)
                
                
                courses.removeAll(where: {$0.id == courseId})
                
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
