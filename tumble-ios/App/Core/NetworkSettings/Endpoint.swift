//
//  Endpoint.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

enum Endpoint {
    
    // SCHEDULE, SEARCH
    case searchProgramme(searchQuery: String, schoolId: String)
    case schedule(scheduleId: String, schoolId: String)
    
    // USERS, EVENTS, RESOURCES
    case userEvents(sessionToken: String, schoolId: String)
    case resourceAvailabilities(sessionToken: String, schoolId: String, resourceId: String, date: String)
    case allResources(sessionToken: String, schoolId: String)
    case userBookings(schoolId: String, sessionToken: String)
    case login(schoolId: String)
    case users(schoolId: String)
    case registerAllEvents(schoolId: String, sessionToken: String)
    case registerEvent(eventId: String, schoolId: String, sessionToken: String)
    case unregisterEvent(eventId: String, schoolId: String, sessionToken: String)
    
    // FCM TOPICS
    case news
    
    var url: URL {
        
        var components = URLComponents()
        let networkSettings = NetworkSettings()
        
        components.host = networkSettings.tumbleUrl
        components.port = networkSettings.port
        components.scheme = networkSettings.scheme
        
        switch self {
        case .searchProgramme(searchQuery: let searchQuery, schoolId: let schoolId):
            components.path = "/api/schedules/search"
            components.queryItems = [
                URLQueryItem(name: "searchQuery", value: searchQuery),
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .schedule(scheduleId: let scheduleId, schoolId: let schoolId):
            components.path = "/api/schedules/\(scheduleId)"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .userEvents(sessionToken: let sessionToken, schoolId: let schoolId):
            components.path = "/api/users/events/"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId),
                URLQueryItem(name: "sessionToken", value: sessionToken)
                
            ]
        case .resourceAvailabilities(sessionToken: let sessionToken, schoolId: let schoolId, resourceId: let resourceId, date: let date):
            components.path = "/api/resources/"
            components.queryItems = [
                URLQueryItem(name: "sessionToken", value: sessionToken),
                URLQueryItem(name: "schoolId", value: schoolId),
                URLQueryItem(name: "resourceId", value: resourceId),
                URLQueryItem(name: "date", value: date)
            ]
        case .userBookings(schoolId: let schoolId, sessionToken: let sessionToken):
            components.path = "/api/resources/userbookings"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId),
                URLQueryItem(name: "sessionToken", value: sessionToken)
            ]
        case .login(schoolId: let schoolId):
            components.path = "/api/users/login"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .users(schoolId: let schoolId):
            components.path = "/api/users"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .registerAllEvents(schoolId: let schoolId, sessionToken: let sessionToken):
            components.path = "/api/users/events/register/all"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId),
                URLQueryItem(name: "sessionToken", value: sessionToken)
            ]
        case .registerEvent(eventId: let eventId, schoolId: let schoolId, sessionToken: let sessionToken):
            components.path = "/api/users/events/register/\(eventId)"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId),
                URLQueryItem(name: "sessionToken", value: sessionToken)
            ]
        case .unregisterEvent(eventId: let eventId, schoolId: let schoolId, sessionToken: let sessionToken):
            components.path = "/api/users/events/unregister/\(eventId)"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId),
                URLQueryItem(name: "sessionToken", value: sessionToken)
            ]
        case .news:
            components.path = "/api/misc/news"
        case .allResources(sessionToken: let sessionToken, schoolId: let schoolId):
            components.path = "/api/resources/all"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId),
                URLQueryItem(name: "sessionToken", value: sessionToken)
            ]
        }
        return components.url!
    }
    
}
