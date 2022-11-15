//
//  APITypes.swift
//  ios-tumble
//
//  Created by Adis Veletanlic on 11/15/22.
//

import Foundation

extension API {
    enum Types {
        
        enum Nullable {
            // MARK: - Encode/decode helpers
            class JSONNull: Codable, Hashable {

                public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
                    return true
                }

                public func hash(into hasher: inout Hasher) {
                        hasher.combine(0)
                    }

                public init() {}

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if !container.decodeNil() {
                        throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
                    }
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    try container.encodeNil()
                }
            }
        }
        
        enum Response {
            
            // ------ SCHEDULE ------
            // ----------------------
            // MARK: - Schedule
            struct Schedule: Codable {
                let cachedAt, id: String
                let days: [Day]

                enum CodingKeys: String, CodingKey {
                    case cachedAt
                    case id = "_id"
                    case days
                }
            }

            // MARK: - Day
            struct Day: Codable {
                let name, date: String
                let isoString: Date
                let weekNumber: Int
                let events: [Event]
            }

            // MARK: - Event
            struct Event: Codable {
                let id, title: String
                let course: Course
                let timeStart, timeEnd: Date
                let locations: [Location]
                let teachers: [Teacher]
                let isSpecial: Bool
                let lastModified: Date
            }

            // MARK: - Course
            struct Course: Codable {
                let id, swedishName, englishName: String
            }

            // MARK: - Location
            struct Location: Codable {
                let id, name, building, floor: String
                let maxSeats: String
            }

            // MARK: - Teacher
            struct Teacher: Codable {
                let id, firstName, lastName: String
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
                let eventStart, eventEnd, lastSignupDate: Date
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
                let eventStart, eventEnd, firstSignupDate: Date
            }
            
            
            // ------ KronoX resources
            // MARK: - KronoxCompleteSchoolResourceElement
            struct KronoxCompleteUserResource: Codable {
                let id, name: String
                let timeSlots, locationIDS, date, availabilities: JSONNull?

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
                let date: Date
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
                let from, to: Date
                let duration: String
            }
        }
        
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
        
        enum Endpoint {
            case searchProgramme(searchQuery: String, schoolId: String)
            case schedule(scheduleId: String, schoolId: String)
            case userEvents(sessionToken: String, schoolId: String)
            case refreshSession(refreshToken: String, schoolId: String)
            case schoolResources(sessionToken: String, schoolId: String)
            case resourceAvailabilities(sessionToken: String, schoolId: String, resourceId: String, date: String)
            case userBookings(sessionToken: String, schoolId: String)
            
            var url: URL {
                var components = URLComponents()
                components.host = "tumble.hkr.se"
                components.scheme = "https"
                switch self {
                case .searchProgramme(searchQuery: let searchQuery, schoolId: let schoolId):
                    components.path = "/schedules/search"
                    components.queryItems = [
                        URLQueryItem(name: "searchQuery", value: searchQuery),
                        URLQueryItem(name: "schoolId", value: schoolId)
                    ]
                case .schedule(scheduleId: let scheduleId, schoolId: let schoolId):
                    components.path = "/schedules/"
                    components.queryItems = [
                        URLQueryItem(name: "scheduleId", value: scheduleId),
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
                }
                return components.url!
            }
            
        }
        
        enum Method: String {
            case get
            case post
            case put
        }
    }
}
