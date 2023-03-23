//
//  EventExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import Foundation

extension Response.Event {
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        dictionary["title"] = self.title
        dictionary["from"] = self.from
        dictionary["to"] = self.to
        dictionary["id"] = self.id
        dictionary["isSpecial"] = self.isSpecial
        dictionary["lastModified"] = self.lastModified
        
        var courseDict: [String: String] = [:]
        courseDict["englishName"] = self.course.englishName
        courseDict["swedishName"] = self.course.englishName
        courseDict["id"] = self.course.id
        dictionary["course"] = courseDict
        
        var locationsArray: [[String: Any]] = []
        for location in self.locations {
            var locationDict: [String: Any] = [:]
            locationDict["name"] = location.name
            locationDict["id"] = location.id
            locationDict["building"] = location.building
            locationDict["floor"] = location.floor
            locationDict["maxSeats"] = location.maxSeats // Int
            locationsArray.append(locationDict)
        }
        dictionary["locations"] = locationsArray
        
        var teachersArray: [[String: String]] = []
        for teacher in self.teachers {
            var teacherDict: [String: String] = [:]
            teacherDict["firstName"] = teacher.firstName
            teacherDict["lastName"] = teacher.lastName
            teacherDict["id"] = teacher.id
            teachersArray.append(teacherDict)
        }
        dictionary["teachers"] = teachersArray
        
        return dictionary
    }
}

extension [Response.Event] {
    
    func sorted() -> [Response.Event] {
        return self.sorted(by: {
            // Ascending order
            return eventDateFormatter.date(from: $0.from)! < eventDateFormatter.date(from: $1.from)!
        })
    }
}
