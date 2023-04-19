//
//  AccountViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/27/22.
//

import Foundation
import Combine

/// ViewModel for the account page of the app.
/// It handles the signing in of users, registering and unregistering
/// for KronoX events, and booking and unbooking of resources.
final class AccountViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var userController: UserController
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    @Inject var schoolManager: SchoolManager
    
    @Published var schoolId: Int = -1
    @Published var schoolName: String = ""
    @Published var status: AccountViewStatus = .unAuthenticated
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var userBookings: Response.KronoxUserBookings? = nil
    @Published var registeredEventSectionState: GenericPageStatus = .loading
    @Published var bookingSectionState: GenericPageStatus = .loading
    @Published var error: Response.ErrorMessage? = nil
    @Published var resourceDetailsSheetModel: ResourceDetailSheetModel? = nil
    @Published var examDetailSheetModel: ExamDetailSheetModel? = nil
    
    private var resourceSectionDataTask: URLSessionDataTask? = nil
    private var eventSectionDataTask: URLSessionDataTask? = nil
    
    var userDisplayName: String? {
       return userController.user?.name
    }
    
    var username: String? {
        return userController.user?.username
    }
    
    var autoSignupEnabled: Bool {
        return userController.autoSignup
    }
    
    /// AccountViewModel is responsible for instantiating
    /// the viewmodel used in its child views it navigates to
    lazy var resourceViewModel: ResourceViewModel = viewModelFactory.makeViewModelResource()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setUpDataPublishers()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            if self.userController.autoSignup {
                self.registerAutoSignup(completion: { _ in })
            } else {
                AppLogger.shared.debug("User has not enabled auto signup for events")
            }
        }
    }
    
    func setUpDataPublishers() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let authStatusPublisher = self.userController.$authStatus
            let schoolIdPublisher = self.preferenceService.$schoolId
            
            Publishers.CombineLatest(authStatusPublisher, schoolIdPublisher)
                .receive(on: DispatchQueue.main)
                .sink { authStatus, schoolId in
                    switch authStatus {
                    case .authorized:
                        self.status = .authenticated
                        self.getUserEventsForSection()
                        self.getUserBookingsForSection()
                    case .unAuthorized:
                        self.status = .unAuthenticated
                    }
                    self.schoolId = schoolId
                    self.schoolName = self.schoolManager.getSchools().first(where: { $0.id == schoolId })?.name ?? ""
                }
                .store(in: &self.cancellables)
        }
    }
    
    
    func removeUserBooking(where id: String) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.userBookings?.removeAll { $0.id == id }
        }
    }
    
    /// This is a caching approach to avoid a network call after user
    /// unregisters for an event in account page, and instead modify it in place,
    /// since network errors can occur.
    func removeUserEvent(where id: String) -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            if var mutRegisteredEvents = self.completeUserEvent?.registeredEvents,
               var mutUnregisteredEvents = self.completeUserEvent?.unregisteredEvents {
                // Find subject in current struct
                let eventRemoved = mutRegisteredEvents.first {
                    $0.eventId == id
                }
                // Add to new array
                if let eventRemoved = eventRemoved {
                    mutUnregisteredEvents.append(eventRemoved)
                }
                mutRegisteredEvents.removeAll {
                    $0.eventId == id
                }
                DispatchQueue.main.async {
                    // Rebuild user events
                    self.completeUserEvent = Response.KronoxCompleteUserEvent(
                        upcomingEvents: self.completeUserEvent?.upcomingEvents,
                        registeredEvents: mutRegisteredEvents, // Insert modified events
                        availableEvents: self.completeUserEvent?.availableEvents,
                        unregisteredEvents: mutUnregisteredEvents
                    )
                }
            }
        }
    }
    
    func login(username: String, password: String, createToast: @escaping (Bool) -> Void ) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.status = .loading
            DispatchQueue.global(qos: .userInitiated).async {
                self.userController.logIn(
                    username: username,
                    password: password)
            }
        }
    }
    
    
    /// Retrieve user events for resource section
    func getUserEventsForSection(tries: Int = 0) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.registeredEventSectionState = .loading
        }
        userController.authenticateAndExecute(
            schoolId: schoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userEvents(schoolId: String(schoolId))
                    self.eventSectionDataTask = self.kronoxManager.get(request, refreshToken: refreshToken,
                    then: { (result: Result<Response.KronoxCompleteUserEvent?, Response.ErrorMessage>) in
                        switch result {
                        case .success(let events):
                            DispatchQueue.main.async {
                                self.completeUserEvent = events
                                self.registeredEventSectionState = .loaded
                            }
                        case .failure(let failure):
                            AppLogger.shared.critical("Could not get user events: \(failure)")
                            DispatchQueue.main.async {
                                self.registeredEventSectionState = .error
                            }
                        }
                    })
                case .failure:
                    DispatchQueue.main.async {
                        self.registeredEventSectionState = .error
                    }
                }
            })
        cancelDataTaskIfTabChanged(dataTask: eventSectionDataTask)
    }


    func getUserBookingsForSection(tries: Int = 0) {
        DispatchQueue.main.async {
            self.bookingSectionState = .loading
        }
        userController.authenticateAndExecute(
            schoolId: schoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userBookings(schoolId: String(schoolId))
                    self.resourceSectionDataTask = self.kronoxManager.get(request, refreshToken: refreshToken,
                       then: { [weak self] (result: Result<Response.KronoxUserBookings, Response.ErrorMessage>) in
                        guard let self = self else { return }
                        switch result {
                        case .success(let bookings):
                            DispatchQueue.main.async {
                                self.bookingSectionState = .loaded
                                self.userBookings = bookings
                            }
                            self.checkNotificationsForUserBookings(bookings: bookings)
                        case .failure(let failure):
                            AppLogger.shared.debug("\(failure)")
                            DispatchQueue.main.async {
                                self.bookingSectionState = .error
                            }
                        }
                    })
                case .failure:
                    DispatchQueue.main.async {
                        self.bookingSectionState = .error
                        self.registeredEventSectionState = .error
                        self.completeUserEvent = nil
                    }
                }
            })
        cancelDataTaskIfTabChanged(dataTask: resourceSectionDataTask)
    }
    
    
    func unregisterForEvent(
        tries: Int = 0,
        eventId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        userController.authenticateAndExecute(
            schoolId: schoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(schoolId))
                    let _ = self.kronoxManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
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
    
    func toggleAutoSignup(value: Bool) {
        userController.autoSignup = value
        if value {
            registerAutoSignup(completion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.getUserEventsForSection()
                case .failure:
                    break
                }
            })
        }
    }
    
    func checkNotificationsForUserBookings(bookings: Response.KronoxUserBookings? = nil) -> Void {
        AppLogger.shared.debug("Checking for notifications to set for user booked resources ...")
        if let userBookings = bookings {
            scheduleBookingNotifications(for: userBookings)
            return
        }
        userController.authenticateAndExecute(
            schoolId: schoolId,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userBookings(schoolId: String(schoolId))
                    self.resourceSectionDataTask = self.kronoxManager.get(request, refreshToken: refreshToken,
                       then: { (result: Result<Response.KronoxUserBookings, Response.ErrorMessage>) in
                        switch result {
                        case .success(let bookings):
                            self.scheduleBookingNotifications(for: bookings)
                        case .failure(let failure):
                            AppLogger.shared.debug("\(failure)")
                            DispatchQueue.main.async {
                                self.bookingSectionState = .error
                            }
                        }
                    })
                case .failure:
                    DispatchQueue.main.async {
                        self.bookingSectionState = .error
                        self.registeredEventSectionState = .error
                        self.completeUserEvent = nil
                    }
                }
            })
    }
}
