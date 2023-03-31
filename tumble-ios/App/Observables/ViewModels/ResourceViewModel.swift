//
//  ResourceViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-26.
//

import Foundation

@MainActor final class ResourceViewModel: ObservableObject {
    
    @Inject var userController: UserController
    @Inject var networkManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    
    @Published var school: School?
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var allResources: Response.KronoxResources? = nil
    @Published var resourceBookingPageState: PageState = .loading
    @Published var eventBookingPageState: PageState = .loading
    @Published var error: Response.ErrorMessage? = nil
    
    init () {
        self.school = preferenceService.getDefaultSchool()
    }
    
    
    func getUserEventsForPage(tries: Int = 0, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.eventBookingPageState = .loading
        }
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userEvents(schoolId: String(schoolId))
                    let _ = networkManager.get(request, refreshToken: refreshToken,
                    then: { [unowned self] (result: Result<Response.KronoxCompleteUserEvent?, Response.ErrorMessage>) in
                        switch result {
                        case .success(let events):
                            AppLogger.shared.info("Successfully loaded events")
                            DispatchQueue.main.async {
                                self.completeUserEvent = events
                                self.eventBookingPageState = .loaded
                            }
                        case .failure(let failure):
                            AppLogger.shared.info("\(failure)")
                            DispatchQueue.main.async {
                                self.eventBookingPageState = .error
                            }
                        }
                    })
                case .failure(let error):
                    AppLogger.shared.info("Failed to get events: \(error)")
                    DispatchQueue.main.async {
                        self.eventBookingPageState = .error
                    }
                }
            })
    }
    
    func registerForEvent(
        tries: Int = 0,
        eventId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.eventBookingPageState = .loading
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.registerEvent(eventId: eventId, schoolId: String(schoolId))
                    let _ = networkManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { (result: Result<Response.Empty, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(.internal(reason: "\(error)")))
                            }
                        }
                    })
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: "\(error)")))
                    }
                }
            })
    }
    
    func unregisterForEvent(
        tries: Int = 0,
        eventId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.eventBookingPageState = .loading
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(schoolId))
                    let _ = networkManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { (result: Result<Response.Empty, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(.internal(reason: "\(error)")))
                            }
                        }
                    })
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: "\(error)")))
                    }
                }
            })
    }
    
    func getAllResourceData(tries: Int = 0, date: Date) -> Void {
        self.resourceBookingPageState = .loading
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.allResources(schoolId: String(schoolId), date: date)
                    let _ = self.networkManager.get(request, refreshToken: refreshToken,
                    then: { [unowned self] (result: Result<Response.KronoxResources?, Response.ErrorMessage>) in
                        switch result {
                        case .success(let resources):
                            DispatchQueue.main.async {
                                self.allResources = resources
                                self.resourceBookingPageState = .loaded
                            }
                        case .failure(let error):
                            AppLogger.shared.info("\(error)")
                            DispatchQueue.main.async {
                                self.resourceBookingPageState = .error
                                self.error = error
                            }
                        }
                    })
                case .failure:
                    DispatchQueue.main.async {
                        self.resourceBookingPageState = .error
                    }
                }
                
            })
    }
    
    func createNotificationForBooking(id: String) -> Void {
        // TODO: Add notification for user to confirm
    }
    
    func bookResource(
        resourceId: String,
        date: Date,
        availabilityValue: Response.AvailabilityValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let requestUrl = Endpoint.bookResource(
                        schoolId: String(schoolId)
                    )
                    let requestBody = Request.BookKronoxResource(
                        resourceId: resourceId,
                        date: isoDateFormatterFract.string(from: date),
                        slot: availabilityValue
                    )
                    let _ = self.networkManager.put(
                        requestUrl,
                        refreshToken: refreshToken,
                        body: requestBody) {
                        (result: Result<Response.KronoxUserBookingElement?, Response.ErrorMessage>) in
                        switch result {
                        case .success:
                            AppLogger.shared.info("Booked resource \(resourceId)")
                            completion(.success(()))
                        case .failure(let error):
                            if error.statusCode == 202 {
                                completion(.success(()))
                            } else {
                                AppLogger.shared.critical("Failed to book resource: \(error)")
                                completion(.failure(.internal(reason: "\(error)")))
                            }
                        }
                    }
                case .failure(let error):
                    AppLogger.shared.critical("\(error)")
                    completion(.failure(.internal(reason: "\(error)")))
                }
            }
        )
    }
    
    func unbookResource(bookingId: String, completion: @escaping (Result<Void, Error>) -> Void) -> Void {
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let requestUrl: Endpoint = .unbookResource(schoolId: String(schoolId), bookingId: bookingId)
                    let _ = self.networkManager.put(requestUrl, refreshToken: refreshToken, body: Request.Empty()) {
                        (result: Result<Response.Empty, Response.ErrorMessage>) in
                        switch result {
                        case .success:
                            AppLogger.shared.info("Unbooked resource")
                            self.notificationManager.cancelNotification(for: bookingId)
                            completion(.success(()))
                        case .failure(let error):
                            AppLogger.shared.critical("Failed to unbook resource: \(bookingId)")
                            completion(.failure(.internal(reason: "\(error)")))
                        }
                    }
                case .failure(let error):
                    AppLogger.shared.critical("\(error)")
                    completion(.failure(.internal(reason: "\(error)")))
                }
            })
    }
}

extension ResourceViewModel {
    
    /// Wrapper function that is meant to be used on functions
    /// that require authentication to be active before processing
    fileprivate func authenticateAndExecute(
        tries: Int = 0,
        school: School?,
        refreshToken: Token?,
        execute: @escaping (Result<(Int, String), Error>) -> Void
    ) {
        guard let school = school,
              let refreshToken = refreshToken,
              !refreshToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.info("Attempting auto login ...")
                userController.autoLogin { [unowned self] in
                    self.authenticateAndExecute(
                        tries: tries + 1,
                        school: school,
                        refreshToken: refreshToken,
                        execute: execute
                    )
                }
            } else {
                execute(.failure(.internal(reason: "Could not authenticate user")))
            }
            return
        }
        execute(.success((school.id, refreshToken.value)))
    }
    
}
