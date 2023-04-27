//
//  DummyDataFactory.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-25.
//

import Foundation

class DummyDataFactory {
    func getDummyKronoxResources() -> Response.KronoxResources {
        let timeSlot1 = Response.TimeSlot(id: 1, from: "2023-05-01T09:00:00", to: "2023-05-01T10:00:00", duration: "01:00:00")
        let timeSlot2 = Response.TimeSlot(id: 2, from: "2023-05-01T10:00:00", to: "2023-05-01T11:00:00", duration: "01:00:00")
        let timeSlot3 = Response.TimeSlot(id: 3, from: "2023-05-01T11:00:00", to: "2023-05-01T12:00:00", duration: "01:00:00")
        let timeSlots1 = [timeSlot1, timeSlot2, timeSlot3]

        let timeSlot4 = Response.TimeSlot(id: 4, from: "2023-05-01T14:00:00", to: "2023-05-01T15:00:00", duration: "01:00:00")
        let timeSlot5 = Response.TimeSlot(id: 5, from: "2023-05-01T15:00:00", to: "2023-05-01T16:00:00", duration: "01:00:00")
        let timeSlot6 = Response.TimeSlot(id: 6, from: "2023-05-01T16:00:00", to: "2023-05-01T17:00:00", duration: "01:00:00")
        let timeSlots2 = [timeSlot4, timeSlot5, timeSlot6]

        let availabilityValue1 = Response.AvailabilityValue(availability: .available, locationID: "5678", resourceType: "Building", timeSlotID: "1", bookedBy: nil)
        let availabilityValue2 = Response.AvailabilityValue(availability: .booked, locationID: "9012", resourceType: "Building Lab", timeSlotID: "4", bookedBy: "Jane")
        let availabilities1 = ["2023-05-01": [1: availabilityValue1]]
        let availabilities2 = ["2023-05-01": [4: availabilityValue2]]

        let resource1 = Response.KronoxResourceElement(id: "1234", name: "Building 1", timeSlots: timeSlots1, date: "2023-05-01", locationIDS: ["5678"], availabilities: availabilities1)
        let resource2 = Response.KronoxResourceElement(id: "5678", name: "Building Lab 2", timeSlots: timeSlots2, date: "2023-05-01", locationIDS: ["9012"], availabilities: availabilities2)
        let kronoxResources = [resource1, resource2]
        return kronoxResources
    }

    func getDummyKronoxCompleteUserEvent() -> Response.KronoxCompleteUserEvent {
        let upcomingEvent1 = Response.UpcomingKronoxUserEvent(title: "Workshop on Machine Learning", type: "Workshop", eventStart: "2023-05-01T10:00:00", eventEnd: "2023-05-01 12:00:00", firstSignupDate: "2023-04-25T10:00:00")
        let upcomingEvent2 = Response.UpcomingKronoxUserEvent(title: "Guest Lecture on Quantum Computing", type: "Lecture", eventStart: "2023-05-02 14:00:00", eventEnd: "2023-05-02 16:00:00", firstSignupDate: "2023-04-26T10:00:00")
        let upcomingEvents = [upcomingEvent1, upcomingEvent2]

        let availableEvent1 = Response.AvailableKronoxUserEvent(eventId: "1234", title: "Python Programming Bootcamp", type: "Bootcamp", eventStart: "2023-05-10T09:00:00", eventEnd: "2023-05-20T17:00:00", lastSignupDate: "2023-05-01T17:00:00", participatorID: nil, supportID: "5678", anonymousCode: "abcd1234", isRegistered: false, supportAvailable: true, requiresChoosingLocation: true)
        let availableEvent2 = Response.AvailableKronoxUserEvent(eventId: "5678", title: "iOS Development Workshop", type: "Workshop", eventStart: "2023-05-15 10:00:00", eventEnd: "2023-05-15 14:00:00", lastSignupDate: "2023-05-10T17:00:00", participatorID: nil, supportID: nil, anonymousCode: "efgh5678", isRegistered: false, supportAvailable: false, requiresChoosingLocation: false)
        let availableEvents = [availableEvent1, availableEvent2]

        let registeredEvent1 = Response.AvailableKronoxUserEvent(eventId: "9012", title: "Blockchain Technology Conference", type: "Conference", eventStart: "2023-05-08T08:00:00", eventEnd: "2023-05-10T17:00:00", lastSignupDate: "2023-05-01T17:00:00", participatorID: "1111", supportID: "2222", anonymousCode: "11112", isRegistered: true, supportAvailable: true, requiresChoosingLocation: true)
        let registeredEvent2 = Response.AvailableKronoxUserEvent(eventId: "3456", title: "Agile Methodologies Workshop", type: "Workshop", eventStart: "2023-05-12T13:00:00", eventEnd: "2023-05-12T17:00:00", lastSignupDate: "2023-05-10T17:00:00", participatorID: "3333", supportID: nil, anonymousCode: "12323", isRegistered: true, supportAvailable: false, requiresChoosingLocation: false)
        let registeredEvents = [registeredEvent1, registeredEvent2]

        let kronoxCompleteUserEvent = Response.KronoxCompleteUserEvent(upcomingEvents: upcomingEvents, registeredEvents: registeredEvents, availableEvents: availableEvents, unregisteredEvents: [])
        return kronoxCompleteUserEvent
    }
    
    func getDummyKronoxCompleteUserResource() -> Response.KronoxResourceElement {
        let timeSlot1 = Response.TimeSlot(id: 1, from: "2023-05-01T09:00:00", to: "2023-05-01T10:00:00", duration: "01:00:00")
        let timeSlot2 = Response.TimeSlot(id: 2, from: "2023-05-01T10:00:00", to: "2023-05-01T11:00:00", duration: "01:00:00")
        let timeSlot3 = Response.TimeSlot(id: 3, from: "2023-05-01T11:00:00", to: "2023-05-01T12:00:00", duration: "01:00:00")
        let timeSlots = [timeSlot1, timeSlot2, timeSlot3]

        let availabilityValue1 = Response.AvailabilityValue(availability: .available, locationID: "1234", resourceType: "Room", timeSlotID: "1", bookedBy: nil)
        let availabilityValue2 = Response.AvailabilityValue(availability: .booked, locationID: "5678", resourceType: "Equipment", timeSlotID: "2", bookedBy: "John")
        let availabilities = ["2023-05-01": [1: availabilityValue1, 2: availabilityValue2]]

        let kronoxResourceElement = Response.KronoxResourceElement(id: "abcd1234", name: "Conference Room A", timeSlots: timeSlots, date: "2023-05-01", locationIDS: ["1234", "5678"], availabilities: availabilities)
        return kronoxResourceElement
    }

    func getDummyDataUpcomingKronoxUserEvent() -> Response.UpcomingKronoxUserEvent {
        let upcomingEvent = Response.UpcomingKronoxUserEvent(title: "Guest Lecture on Quantum Computing", type: "Lecture", eventStart: "2023-05-02T14:00:00", eventEnd: "2023-05-02T16:00:00", firstSignupDate: "2023-04-26T10:00:00")
        return upcomingEvent
    }
    
    func getDummyDataAvailableKronoxUserEvent() -> Response.AvailableKronoxUserEvent {
        let availableEvent = Response.AvailableKronoxUserEvent(eventId: "1234", title: "Python Programming Bootcamp", type: "Bootcamp", eventStart: "2023-05-10T09:00:00", eventEnd: "2023-05-20T17:00:00", lastSignupDate: "2023-05-01T17:00:00", participatorID: nil, supportID: "5678", anonymousCode: "abcd1234", isRegistered: false, supportAvailable: true, requiresChoosingLocation: true)
        return availableEvent
    }
    
    func getDummyDataKronoxUserBookingElement() -> [Response.KronoxUserBookingElement] {
        let timeSlot = Response.TimeSlot(id: 1, from: "2023-06-02T14:00:00", to: "2023-05-01T10:00:00", duration: "01:00:00")
        let bookingElement = Response.KronoxUserBookingElement(id: "abcd1234", resourceID: "1234", timeSlot: timeSlot, locationID: "5678", showConfirmButton: true, showUnbookButton: true, confirmationOpen: "2023-04-30T12:00:00", confirmationClosed: "2023-05-01T12:00:00")
        return [bookingElement]
    }
    
    func getDummyDataKronoxEventRegistration() -> Response.KronoxEventRegistration {
        let successfulRegistration1 = Response.Registration(id: "1234", title: "Python Programming Bootcamp", type: "Bootcamp", eventStart: "2023-05-10T09:00:00", eventEnd: "2023-05-20T17:00:00", lastSignupDate: "2023-05-01T17:00:00", participatorID: "5678", supportID: nil, anonymousCode: nil, isRegistered: true, supportAvailable: false, requiresChoosingLocation: true)
        let successfulRegistration2 = Response.Registration(id: "5678", title: "iOS Development Workshop", type: "Workshop", eventStart: "2023-05-15T10:00:00", eventEnd: "2023-05-15T14:00:00", lastSignupDate: "2023-05-10T17:00:00", participatorID: "9012", supportID: "3456", anonymousCode: nil, isRegistered: true, supportAvailable: true, requiresChoosingLocation: false)
        let successfulRegistrations = [successfulRegistration1, successfulRegistration2]

        let failedRegistration1 = Response.Registration(id: "9012", title: "Blockchain Technology Conference", type: "Conference", eventStart: "2023-05-08T08:00:00", eventEnd: "2023-05-10T17:00:00", lastSignupDate: "2023-05-01T17:00:00", participatorID: nil, supportID: "1111", anonymousCode: "abcd1234", isRegistered: false, supportAvailable: true, requiresChoosingLocation: true)
        let failedRegistration2 = Response.Registration(id: "3456", title: "Artificial Intelligence Symposium", type: "Symposium", eventStart: "2023-05-12T13:00:00", eventEnd: "2023-05-12T17:00:00", lastSignupDate: "2023-05-07T17:00:00", participatorID: nil, supportID: nil, anonymousCode: nil, isRegistered: false, supportAvailable: true, requiresChoosingLocation: false)
        let failedRegistrations = [failedRegistration1, failedRegistration2]

        let kronoxEventRegistration = Response.KronoxEventRegistration(successfulRegistrations: successfulRegistrations, failedRegistrations: failedRegistrations)
        return kronoxEventRegistration
    }
}
