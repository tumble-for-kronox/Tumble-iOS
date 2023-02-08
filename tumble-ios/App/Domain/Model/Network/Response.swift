//
//  Response.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

enum Response {
    
    // ------ SCHEDULE ------
    // ----------------------
    
    // MARK: - Schedule
    struct Schedule: Codable, Hashable {
        static func == (lhs: Response.Schedule, rhs: Response.Schedule) -> Bool {
            return lhs.id == rhs.id
        }
        
        let id, cachedAt: String
        let days: [Day]
    }

    // MARK: - Day
    struct Day: Identifiable, Codable, Hashable {
        static func == (lhs: Response.Day, rhs: Response.Day) -> Bool {
            return lhs.name == rhs.name && lhs.isoString == rhs.isoString && lhs.weekNumber == rhs.weekNumber
        }
        
        let name: String
        let date, isoString: String
        let weekNumber: Int
        let events: [Event]
        var id: UUID = UUID()
    }

    // MARK: - Event
    struct Event: Codable, Equatable, Hashable {
        
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
        
    }

    // MARK: - Course
    struct Course: Codable, Hashable {
        let id: String
        let swedishName, englishName: String
    }

    // MARK: - Location
    struct Location: Codable, Hashable {
        let id: String
        let name: String
        let building, floor: String
        let maxSeats: Int
    }

    // MARK: - Teacher
    struct Teacher: Codable, Hashable {
        let id: String
        let firstName: String
        let lastName: String
    }
    
    
    // ------ SEARCH ------
    // --------------------
    // MARK: - SearchResponse
    struct Search: Codable {
        let count: Int
        let items: [Programme]
    }

    // MARK: - Item
    struct Programme: Codable {
        let id, title, subtitle: String
    }
    
    
    // ------ USER ------
    // ------------------
    // MARK: - UserSession
    struct KronoxUser: Codable {
        let name, username, sessionToken: String
    }
    
    
    // ------ KronoX events ------
    // --------------------------
    // MARK: - KronoxCompleteUserEvent
    struct KronoxCompleteUserEvent: Codable {
        let upcomingEvents: [UpcomingKronoxUserEvent]
        let registeredEvents, availableEvents: [AvailableKronoxUserEvent]
    }

    // MARK: - AvailableKronoxUserEvent
    struct AvailableKronoxUserEvent: Codable {
        let id, title, type: String
        let eventStart, eventEnd, lastSignupDate: String
        let participatorID, supportID, anonymousCode: String
        let isRegistered, supportAvailable, requiresChoosingLocation: Bool

        enum CodingKeys: String, CodingKey {
            case id, title, type, eventStart, eventEnd, lastSignupDate
            case participatorID = "participatorId"
            case supportID = "supportId"
            case anonymousCode, isRegistered, supportAvailable, requiresChoosingLocation
        }
    }

    // MARK: - UpcomingKronoxUserEvent
    struct UpcomingKronoxUserEvent: Codable {
        let title, type: String
        let eventStart, eventEnd, firstSignupDate: String
    }
    
    
    // ------ KronoX resources
    // MARK: - KronoxCompleteSchoolResourceElement
    struct KronoxCompleteUserResource: Codable {
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
    struct KronoxResourceData: Codable {
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
    struct Availabilities: Codable {
        let locationID: LocationID

        enum CodingKeys: String, CodingKey {
            case locationID = "locationId"
        }
    }

    // MARK: - LocationID
    struct LocationID: Codable {
        let timeSlotID: TimeSlotID

        enum CodingKeys: String, CodingKey {
            case timeSlotID = "timeSlotId"
        }
    }

    // MARK: - TimeSlotID
    struct TimeSlotID: Codable {
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

    // MARK: - TimeSlot
    struct TimeSlot: Codable {
        let id: Int
        let from, to: String
        let duration: String
    }
}
