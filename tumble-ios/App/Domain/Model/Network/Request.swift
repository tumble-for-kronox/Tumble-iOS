//
//  Request.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

enum Request {
    struct Empty: Codable {
    
    }
    
    struct RegisterUserEvent: Codable {
        let eventId: String
        let schoolId: Int
        let sessionToken: String
    }
    
    struct UnregisterUserEvent: Codable {
        let eventId: String
        let schoolId: Int
        let sessionToken: String
    }
    
    struct RegiserAllUserEvents: Codable {
        let schoolId: Int
        let sessionToken: String
    }
    
    struct SubmitIssue: Codable {
        let title: String
        let description: String
    }
    
    struct BookKronoxResource: Codable {
        let resourceId: String
        let date: String
        let availabilitySlot: String
    }
    
    struct UnbookKronoxResource: Codable {
        let bookingId: String
        let schoolId: Int
        let sessionToken: String
    }
    
    struct KronoxUserLogin: Codable {
        let username: String
        let password: String
    }
}



enum Error: LocalizedError {
    case generic(reason: String)
    case `internal`(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .generic(let reason):
            return reason
        case .internal(let reason):
            return "Internal error: \(reason)"
        }
    }
}
