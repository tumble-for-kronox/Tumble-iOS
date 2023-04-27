//
//  ResourceViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-26.
//

import Combine
import Foundation

final class ResourceViewModel: ObservableObject {
    @Inject var userController: UserController
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    @Inject var schoolManager: SchoolManager
    
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var allResources: Response.KronoxResources? = nil
    @Published var resourceBookingPageState: GenericPageStatus = .loading
    @Published var eventBookingPageState: GenericPageStatus = .loading
    @Published var error: Response.ErrorMessage? = nil
    @Published var selectedPickerDate: Date = .now
    
    @Published var authSchoolId: Int = -1
    private var allResourcesDataTask: URLSessionDataTask? = nil
    private var cancellables = Set<AnyCancellable>()
    private let dummyDataFactory: DummyDataFactory = DummyDataFactory()
    
    init() {
        initialisePipelines()
    }
    
    func initialisePipelines() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.preferenceService.$authSchoolId
                .assign(to: \.authSchoolId, on: self)
                .store(in: &self.cancellables)
        }
    }
    
    func getUserEventsForPage(tries: Int = 0, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.eventBookingPageState = .loading
        }
        userController.authenticateAndExecute(
            authSchoolId: authSchoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userEvents(schoolId: String(schoolId))
                    _ = self.kronoxManager.get(request, refreshToken: refreshToken,
                       then: { (result: Result<Response.KronoxCompleteUserEvent?, Response.ErrorMessage>) in
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
                case .demo:
                    DispatchQueue.main.async {
                        self.completeUserEvent = self.dummyDataFactory.getDummyKronoxCompleteUserEvent()
                        self.eventBookingPageState = .loaded
                    }
                }
            }
        )
    }
    
    func registerForEvent(
        tries: Int = 0,
        eventId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.eventBookingPageState = .loading
        }
        userController.authenticateAndExecute(
            authSchoolId: authSchoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.registerEvent(eventId: eventId, schoolId: String(schoolId))
                    _ = self.kronoxManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
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
                case .demo:
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
            }
        )
    }
    
    func unregisterForEvent(
        tries: Int = 0,
        eventId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.eventBookingPageState = .loading
        }
        userController.authenticateAndExecute(
            authSchoolId: authSchoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(schoolId))
                    _ = self.kronoxManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
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
                case .demo:
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
            }
        )
    }
    
    func getAllResourceData(tries: Int = 0, date: Date) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.resourceBookingPageState = .loading
        }
        userController.authenticateAndExecute(
            authSchoolId: authSchoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.allResources(schoolId: String(schoolId), date: date)
                    self.allResourcesDataTask = self.kronoxManager.get(request, refreshToken: refreshToken,
                       then: { (result: Result<Response.KronoxResources?, Response.ErrorMessage>) in
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
                case .demo:
                    DispatchQueue.main.async {
                        self.allResources = self.dummyDataFactory.getDummyKronoxResources()
                        self.resourceBookingPageState = .loaded
                    }
                }
            }
        )
        cancelDataTaskIfDateChanged(dataTask: allResourcesDataTask, date: selectedPickerDate)
    }
    
    func confirmResource(
        resourceId: String,
        bookingId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        userController.authenticateAndExecute(
            authSchoolId: authSchoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let requestUrl = Endpoint.confirmResource(
                        schoolId: String(schoolId)
                    )
                    let requestBody = Request.ConfirmKronoxResource(
                        resourceId: resourceId,
                        bookingId: bookingId
                    )
                    _ = self.kronoxManager.put(
                        requestUrl,
                        refreshToken: refreshToken,
                        body: requestBody
                    ) {
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
                case .demo:
                    completion(.success(()))
                }
            }
        )
    }
    
    func bookResource(
        resourceId: String,
        date: Date,
        availabilityValue: Response.AvailabilityValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        userController.authenticateAndExecute(
            authSchoolId: authSchoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
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
                    _ = self.kronoxManager.put(
                        requestUrl,
                        refreshToken: refreshToken,
                        body: requestBody
                    ) {
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
                case .demo:
                    completion(.success(()))
                }
            }
        )
    }
    
    func unbookResource(bookingId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        userController.authenticateAndExecute(
            authSchoolId: authSchoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let requestUrl: Endpoint = .unbookResource(schoolId: String(schoolId), bookingId: bookingId)
                    _ = self.kronoxManager.put(
                        requestUrl,
                        refreshToken: refreshToken,
                        body: Request.Empty()
                    ) {
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
                case .demo:
                    completion(.success(()))
                }
            }
        )
    }
}
