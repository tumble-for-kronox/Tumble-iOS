//
//  Endpoint.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

enum Endpoint {
    
    case searchProgramme(searchQuery: String, schoolId: String)
    case schedule(scheduleId: String, schoolId: String)
    case userEvents(sessionToken: String, schoolId: String)
    case refreshSession(refreshToken: String, schoolId: String)
    case schoolResources(sessionToken: String, schoolId: String)
    case resourceAvailabilities(sessionToken: String, schoolId: String, resourceId: String, date: String)
    case userBookings(sessionToken: String, schoolId: String)
    case login(schoolId: String)
    case users(schoolId: String)
    
    var url: URL {
        
        var components = URLComponents()
        let networkSettings = NetworkSettings()
        
        components.host = networkSettings.tumbleUrl
        components.port = networkSettings.port
        components.scheme = networkSettings.scheme
        
        switch self {
        case .searchProgramme(searchQuery: let searchQuery, schoolId: let schoolId):
            components.path = "/schedules/search"
            components.queryItems = [
                URLQueryItem(name: "searchQuery", value: searchQuery),
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .schedule(scheduleId: let scheduleId, schoolId: let schoolId):
            components.path = "/schedules/\(scheduleId)"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .userEvents(sessionToken: let sessionToken, schoolId: let schoolId):
            components.path = "users/events"
            components.queryItems = [
                URLQueryItem(name: "sessionToken", value: sessionToken),
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .refreshSession(refreshToken: let refreshToken, schoolId: let schoolId):
            components.path = "users/refresh"
            components.queryItems = [
                URLQueryItem(name: "refreshToken", value: refreshToken),
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .schoolResources(sessionToken: let sessionToken, schoolId: let schoolId):
            components.path = "resources"
            components.queryItems = [
                URLQueryItem(name: "sessionToken", value: sessionToken),
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .resourceAvailabilities(sessionToken: let sessionToken, schoolId: let schoolId, resourceId: let resourceId, date: let date):
            components.path = "resources/"
            components.queryItems = [
                URLQueryItem(name: "sessionToken", value: sessionToken),
                URLQueryItem(name: "schoolId", value: schoolId),
                URLQueryItem(name: "resourceId", value: resourceId),
                URLQueryItem(name: "date", value: date)
            ]
        case .userBookings(sessionToken: let sessionToken, schoolId: let schoolId):
            components.path = "resources/userbookings"
            components.queryItems = [
                URLQueryItem(name: "sessionToken", value: sessionToken),
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .login(schoolId: let schoolId):
            components.path = "/api/users/login"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        case .users(schoolId: let schoolId):
            components.path = "/users"
            components.queryItems = [
                URLQueryItem(name: "schoolId", value: schoolId)
            ]
        }
        return components.url!
    }
    
}
