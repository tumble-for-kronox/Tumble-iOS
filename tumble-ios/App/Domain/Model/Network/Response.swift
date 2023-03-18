//
//  Response.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

public enum Response {
    
    // MARK: - HTTPResponse
    struct HTTPResponse: Codable {
        let url: String?
        let statusCode: Int
        let headers: Headers?
        
        enum CodingKeys: String, CodingKey {
            case url = "URL"
            case statusCode = "Status Code"
            case headers = "Headers"
        }
        
    }

    // MARK: - Headers
    struct Headers: Codable {
        let contentLength: Int
        let date, server: String

        enum CodingKeys: String, CodingKey {
            case contentLength = "Content-Length"
            case date = "Date"
            case server = "Server"
        }
    }
    
    // ------ SCHEDULE ------
    // ----------------------
    
    // MARK: - Schedule
    struct Schedule: Encodable, Decodable, Hashable {
        static func == (lhs: Response.Schedule, rhs: Response.Schedule) -> Bool {
            return lhs.id == rhs.id
        }
        
        let id, cachedAt: String
        let days: [Day]
    }

    // MARK: - Day
    struct Day: Encodable, Decodable, Hashable {
        static func == (lhs: Response.Day, rhs: Response.Day) -> Bool {
            return lhs.name == rhs.name && lhs.isoString == rhs.isoString && lhs.weekNumber == rhs.weekNumber
        }
        
        let name: String
        let date, isoString: String
        let weekNumber: Int
        let events: [Event]
    }

    // MARK: - Event
    struct Event: Encodable, Decodable, Equatable, Hashable {
        
        static func == (lhs: Response.Event, rhs:  Response.Event) -> Bool {
            return lhs.id == rhs.id
        }
        
        let title: String
        let course: Course
        let from, to: String
        let locations: [Location]
        let teachers: [Teacher]
        let id: String
        let isSpecial: Bool
        let lastModified: String
        
        var dateComponents: DateComponents? {
            let formatter = ISO8601DateFormatter()
            guard let fromDate = formatter.date(from: from) else {
                return nil
            }
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fromDate)
            return components
        }
        
        var uuid: UUID {
            return UUID()
        }
        
    }

    // MARK: - Course
    struct Course: Encodable, Decodable, Hashable {
        let id: String
        let swedishName, englishName: String
    }

    // MARK: - Location
    struct Location: Encodable, Decodable, Hashable {
        let id: String
        let name: String
        let building, floor: String
        let maxSeats: Int
    }

    // MARK: - Teacher
    struct Teacher: Encodable, Decodable, Hashable {
        let id: String
        let firstName: String
        let lastName: String
    }
    
    
    // ------ SEARCH ------
    // --------------------
    // MARK: - SearchResponse
    struct Search: Encodable, Decodable {
        let count: Int
        let items: [Programme]
    }

    // MARK: - Item
    struct Programme: Encodable, Decodable {
        let id, title, subtitle: String
    }
    
    
    // ------ USER ------
    // ------------------
    // MARK: - UserSession
    struct KronoxUser: Encodable, Decodable {
        let name, username, refreshToken, sessionToken: String
    }
    
    
    // ------ KronoX events ------
    // --------------------------
    // MARK: - KronoxCompleteUserEvent
    struct KronoxCompleteUserEvent: Encodable, Decodable {
        let upcomingEvents: [UpcomingKronoxUserEvent]?
        let registeredEvents, availableEvents, unregisteredEvents: [AvailableKronoxUserEvent]?
    }

    // MARK: - AvailableKronoxUserEvent
    struct AvailableKronoxUserEvent: Identifiable, Encodable, Decodable {
        
        var id: UUID {
            return UUID()
        }
        
        let eventId, title, type: String
        let eventStart, eventEnd, lastSignupDate: String
        let participatorID, supportID: String?
        let anonymousCode: String
        let isRegistered, supportAvailable, requiresChoosingLocation: Bool

        enum CodingKeys: String, CodingKey {
            case eventId = "id"
            case title, type, eventStart, eventEnd, lastSignupDate
            case participatorID = "participatorId"
            case supportID = "supportId"
            case anonymousCode, isRegistered, supportAvailable, requiresChoosingLocation
        }
    }

    // MARK: - UpcomingKronoxUserEvent
    struct UpcomingKronoxUserEvent: Identifiable, Encodable, Decodable {
        let title, type: String
        let eventStart, eventEnd, firstSignupDate: String
        
        var id: UUID {
            return UUID()
        }
    }
    
    
    // ------ KronoX resources
    // MARK: - KronoxCompleteSchoolResourceElement
    struct KronoxCompleteUserResource: Encodable, Decodable {
        let id, name: String
        let timeSlots, locationIDS, date, availabilities: Nullable.JSONNull?

        enum CodingKeys: String, CodingKey {
            case id, name, timeSlots
            case locationIDS = "locationIds"
            case date, availabilities
        }
    }
    
    
    // ------ KronoX resource data ------
    // ----------------------------------
    // MARK: - KronoxResourceData
    struct KronoxResourceData: Encodable, Decodable {
        let id, name: String
        let timeSlots: [TimeSlot]
        let locationIDS: [String]
        let date: String
        let availabilities: Availabilities

        enum CodingKeys: String, CodingKey {
            case id, name, timeSlots
            case locationIDS = "locationIds"
            case date, availabilities
        }
    }

    // MARK: - Availabilities
    struct Availabilities: Encodable, Decodable {
        let locationID: LocationID

        enum CodingKeys: String, CodingKey {
            case locationID = "locationId"
        }
    }

    // MARK: - LocationID
    struct LocationID: Encodable, Decodable {
        let timeSlotID: TimeSlotID

        enum CodingKeys: String, CodingKey {
            case timeSlotID = "timeSlotId"
        }
    }

    // MARK: - TimeSlotID
    struct TimeSlotID: Encodable, Decodable {
        let availability: Int
        let locationID, resourceType, timeSlotID, bookedBy: String

        enum CodingKeys: String, CodingKey {
            case availability
            case locationID = "locationId"
            case resourceType
            case timeSlotID = "timeSlotId"
            case bookedBy
        }
    }
    
    typealias KronoxUserBooking = [KronoxUserBookingElement]
    // MARK: - KronoxUserBookingElement
    struct KronoxUserBookingElement: Identifiable, Decodable {
        let id, resourceID: String
        let timeSlot: TimeSlot
        let locationID: String
        let showConfirmButton, showUnbookButton: Bool
        let confirmationOpen, confirmationClosed: String

        enum CodingKeys: String, CodingKey {
            case id
            case resourceID = "resourceId"
            case timeSlot
            case locationID = "locationId"
            case showConfirmButton, showUnbookButton, confirmationOpen, confirmationClosed
        }
    }

    
    // MARK: - TimeSlot
    struct TimeSlot: Encodable, Decodable {
        let id: Int?
        let from, to: String
        let duration: String
    }
    
    // MARK: - KronoxEventRegistration
    struct KronoxEventRegistration: Codable {
        let successfulRegistrations, failedRegistrations: [Registration]?
    }

    // MARK: - Registration
    struct Registration: Codable {
        let id, title, type: String?
        let eventStart, eventEnd, lastSignupDate: String?
        let participatorID, supportID, anonymousCode: String?
        let isRegistered, supportAvailable, requiresChoosingLocation: Bool?

        enum CodingKeys: String, CodingKey {
            case id, title, type, eventStart, eventEnd, lastSignupDate
            case participatorID = "participatorId"
            case supportID = "supportId"
            case anonymousCode, isRegistered, supportAvailable, requiresChoosingLocation
        }
    }

    struct ErrorMessage: Codable, LocalizedError {
        let message: String
    }
    
}
