//
//  ResourceViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-26.
//

import Foundation

@MainActor final class ResourceViewModel: ObservableObject {
    
    @Inject var userController: UserController
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    @Inject var schoolManager: SchoolManager
    
    @Published var school: School?
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var allResources: Response.KronoxResources? = nil
    @Published var resourceBookingPageState: GenericPageStatus = .loading
    @Published var eventBookingPageState: GenericPageStatus = .loading
    @Published var error: Response.ErrorMessage? = nil
    @Published var selectedPickerDate: Date = Date.now
    
    private var allResourcesDataTask: URLSessionDataTask? = nil
    
    init () {
        self.school = preferenceService.getDefaultSchoolName(schools: schoolManager.getSchools())
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
                    let _ = kronoxManager.get(request, refreshToken: refreshToken,
                    then: { [unowned self] (result: Result<Response.KronoxCompleteUserEvent?, Response.ErrorMessage>) in
                        switch result {
                        case .success(let events):
                            AppLogger.shared.debug("Successfully loaded events")
                            DispatchQueue.main.async {
                                self.completeUserEvent = events
                                self.eventBookingPageState = .loaded
                            }
                        case .failure(let failure):
                            AppLogger.shared.debug("\(failure)")
                            DispatchQueue.main.async {
                                self.eventBookingPageState = .error
                            }
                        }
                    })
                case .failure(let failure):
                    AppLogger.shared.critical("Failed to get events: \(failure)")
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
                    let _ = kronoxManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { (result: Result<Response.Empty, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                completion(.success(()))
                            case .failure(let failure):
                                completion(.failure(.internal(reason: "\(failure)")))
                            }
                        }
                    })
                case .failure(let failure):
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: "\(failure)")))
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
                    let _ = kronoxManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { (result: Result<Response.Empty, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                completion(.success(()))
                            case .failure(let failure):
                                completion(.failure(.internal(reason: "\(failure)")))
                            }
                        }
                    })
                case .failure(let failure):
                    DispatchQueue.main.async {
                        completion(.failure(.internal(reason: "\(failure)")))
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
                    self.allResourcesDataTask = self.kronoxManager.get(request, refreshToken: refreshToken,
                    then: { [unowned self] (result: Result<Response.KronoxResources?, Response.ErrorMessage>) in
                        switch result {
                        case .success(let resources):
                            DispatchQueue.main.async {
                                self.allResources = resources
                                self.resourceBookingPageState = .loaded
                            }
                        case .failure(let failure):
                            AppLogger.shared.debug("\(failure)")
                            DispatchQueue.main.async {
                                self.resourceBookingPageState = .error
                                self.error = failure
                            }
                        }
                    })
                case .failure:
                    DispatchQueue.main.async {
                        self.resourceBookingPageState = .error
                    }
                }
            })
        cancelDataTaskIfDateChanged(dataTask: allResourcesDataTask, date: self.selectedPickerDate)
    }
    
    
    func confirmResource(
        resourceId: String,
        bookingId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Void {
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let requestUrl = Endpoint.confirmResource(
                        schoolId: String(schoolId)
                    )
                    let requestBody = Request.ConfirmKronoxResource(
                        resourceId: resourceId,
                        bookingId: bookingId
                    )
                    let _ = self.kronoxManager.put(
                        requestUrl,
                        refreshToken: refreshToken,
                        body: requestBody) {
                        (result: Result<Response.Empty, Response.ErrorMessage>) in
                        switch result {
                        case .success:
                            AppLogger.shared.debug("Confirmed resource \(resourceId)")
                            completion(.success(()))
                        case .failure(let failure):
                            if failure.statusCode == 202 {
                                completion(.success(()))
                            } else {
                                AppLogger.shared.critical("Failed to confirm resource: \(failure)")
                                completion(.failure(.internal(reason: "\(failure)")))
                            }
                        }
                    }
                case .failure(let failure):
                    AppLogger.shared.critical("\(failure)")
                    completion(.failure(.internal(reason: "\(failure)")))
                }
            }
        )
    }
    
    
    func bookResource(
        resourceId: String,
        date: Date,
        availabilityValue: Response.AvailabilityValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Void {
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
                    let _ = self.kronoxManager.put(
                        requestUrl,
                        refreshToken: refreshToken,
                        body: requestBody) {
                        (result: Result<Response.KronoxUserBookingElement?, Response.ErrorMessage>) in
                        switch result {
                        case .success:
                            AppLogger.shared.debug("Booked resource \(resourceId)")
                            completion(.success(()))
                        case .failure(let failure):
                            if failure.statusCode == 202 {
                                completion(.success(()))
                            } else {
                                AppLogger.shared.critical("Failed to book resource: \(failure)")
                                completion(.failure(.internal(reason: "\(failure)")))
                            }
                        }
                    }
                case .failure(let failure):
                    AppLogger.shared.critical("\(failure)")
                    completion(.failure(.internal(reason: "\(failure)")))
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
                    let _ = self.kronoxManager.put(requestUrl, refreshToken: refreshToken, body: Request.Empty()) {
                        (result: Result<Response.Empty, Response.ErrorMessage>) in
                        switch result {
                        case .success:
                            AppLogger.shared.debug("Unbooked resource")
                            self.notificationManager.cancelNotification(for: bookingId)
                            completion(.success(()))
                        case .failure(let failure):
                            AppLogger.shared.critical("Failed to unbook resource: \(bookingId)")
                            completion(.failure(.internal(reason: "\(failure)")))
                        }
                    }
                case .failure(let failure):
                    AppLogger.shared.critical("\(failure)")
                    completion(.failure(.internal(reason: "\(failure)")))
                }
            })
    }
}
