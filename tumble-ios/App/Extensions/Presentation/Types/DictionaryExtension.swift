//
//  DictionaryExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func toEvent() -> Response.Event? {
        guard let title = self["title"] as? String,
            let from = self["from"] as? String,
            let to = self["to"] as? String,
            let id = self["id"] as? String,
            let isSpecial = self["isSpecial"] as? Bool,
            let lastModified = self["lastModified"] as? String,
            let courseDict = self["course"] as? [String: String],
            let locationsArray = self["locations"] as? [[String: Any]],
            let teachersArray = self["teachers"] as? [[String: String]] else {
                return nil
        }
        
        let course = Response.Course(id: courseDict["id"] ?? "",
                                     swedishName: courseDict["swedishName"] ?? "",
                                     englishName: courseDict["englishName"] ?? "")
        
        var locations: [Response.Location] = []
        for locationDict in locationsArray {
            guard let name = locationDict["name"] as? String,
                let locationId = locationDict["id"] as? String,
                let building = locationDict["building"] as? String,
                let floor = locationDict["floor"] as? String,
                let maxSeats = locationDict["maxSeats"] as? Int else {
                    continue
            }
            
            let location = Response.Location(id: locationId, name: name,
                                    building: building,
                                    floor: floor,
                                    maxSeats: maxSeats)
            locations.append(location)
        }
        
        var teachers: [Response.Teacher] = []
        for teacherDict in teachersArray {
            guard let firstName = teacherDict["firstName"],
                let lastName = teacherDict["lastName"],
                let teacherId = teacherDict["id"] else {
                    continue
            }
            
            let teacher = Response.Teacher(id: teacherId, firstName: firstName,
                                           lastName: lastName)
            teachers.append(teacher)
        }
        
        return Response.Event(title: title,
                     course: course,
                     from: from,
                     to: to,
                     locations: locations,
                     teachers: teachers,
                     id: id,
                     isSpecial: isSpecial,
                     lastModified: lastModified)
    }
}

