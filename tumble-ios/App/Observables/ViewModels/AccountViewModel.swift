import Foundation

enum AccountPageViewStatus {
    case loading
    case error
    case initial
}

enum PageState {
    case loading
    case loaded
    case error
}

struct ResourceDetailSheetModel: Identifiable {
    var id: UUID = UUID()
    let resource: Response.KronoxUserBookingElement
}

struct ExamDetailSheetModel: Identifiable {
    var id: UUID = UUID()
    let event: Response.AvailableKronoxUserEvent
}


/// ViewModel for the account page of the app.
/// It handles the signing in of users, registering and unregistering
/// for KronoX events, and booking and unbooking of resources.
@MainActor final class AccountViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var userController: UserController
    @Inject var networkManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    
    @Published var school: School?
    @Published var status: AccountPageViewStatus = .initial
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var userBookings: Response.KronoxUserBookings? = nil
    @Published var registeredEventSectionState: PageState = .loading
    @Published var bookingSectionState: PageState = .loading
    @Published var error: Response.ErrorMessage? = nil
    @Published var resourceDetailsSheetModel: ResourceDetailSheetModel? = nil
    @Published var examDetailSheetModel: ExamDetailSheetModel? = nil
    
    private let jsonEncoder = JSONEncoder.shared
    private var resourceSectionDataTask: URLSessionDataTask? = nil
    private var eventSectionDataTask: URLSessionDataTask? = nil
    
    /// AccountViewModel is responsible for instantiating
    /// the viewmodel used in its child views it navigates to
    let resourceViewModel: ResourceViewModel
    
    init() {
        self.resourceViewModel = viewModelFactory.makeViewModelResource()
        self.school = preferenceService.getDefaultSchool()
        if userController.autoSignup {
            self.registerAutoSignup(completion: { result in
                switch result {
                case .success:
                    break
                case .failure:
                    break
                }
            })
        } else {
            AppLogger.shared.debug("User has not enabled auto signup for events")
        }
        self.checkNotificationsForUserBookings()
    }
    
    func updateViewLocals() -> Void {
        self.school = preferenceService.getDefaultSchool()
    }

    func removeUserBooking(where id: String) -> Void {
        DispatchQueue.main.async {
            self.userBookings?.removeAll {
                $0.id == id
            }
        }
    }
    
    /// This is a caching approach to avoid a network call after user
    /// unregisters for an event in account page, and instead modify it in place,
    /// since network errors can occur.
    func removeUserEvent(where id: String) -> Void {
        if var mutRegisteredEvents = completeUserEvent?.registeredEvents,
           var mutUnregisteredEvents = completeUserEvent?.unregisteredEvents {
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
    
    func login(username: String, password: String, createToast: @escaping (Bool) -> Void ) -> Void {
        self.status = .loading
        self.userController.logIn(
            username: username,
            password: password,
            completion: { [unowned self] success in
                DispatchQueue.main.async {
                    self.status = .initial
                }
                self.getUserEventsForSection()
                self.getUserBookingsForSection()
                createToast(success)
            })
    }
    
    
    /// Retrieve user events for resource section
    func getUserEventsForSection(tries: Int = 0) {
        DispatchQueue.main.async {
            self.registeredEventSectionState = .loading
        }
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userEvents(schoolId: String(schoolId))
                    self.eventSectionDataTask = networkManager.get(request, refreshToken: refreshToken,
                    then: { [unowned self] (result: Result<Response.KronoxCompleteUserEvent?, Response.ErrorMessage>) in
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
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userBookings(schoolId: String(schoolId))
                    self.resourceSectionDataTask = networkManager.get(request, refreshToken: refreshToken,
                       then: { [weak self] (result: Result<Response.KronoxUserBookings, Response.ErrorMessage>) in
                        guard let self = self else { return }
                        switch result {
                        case .success(let bookings):
                            DispatchQueue.main.async {
                                self.bookingSectionState = .loaded
                                self.userBookings = bookings
                            }
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
    
    func toggleAutoSignup(value: Bool) {
        userController.autoSignup = value
        if value {
            registerAutoSignup(completion: { [unowned self] result in
                switch result {
                case .success:
                    self.getUserEventsForSection()
                case .failure:
                    break
                }
            })
        }
    }
    
    func checkNotificationsForUserBookings() -> Void {
        AppLogger.shared.debug("Checking for notifications to set for user booked resources ...")
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userBookings(schoolId: String(schoolId))
                    self.resourceSectionDataTask = networkManager.get(request, refreshToken: refreshToken,
                       then: { [unowned self] (result: Result<Response.KronoxUserBookings, Response.ErrorMessage>) in
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


extension AccountViewModel {
    
    fileprivate func scheduleBookingNotifications(for bookings: Response.KronoxUserBookings) -> Void {
        for booking in bookings {
            if let dateComponents = booking.dateComponentsConfirmation {
                let notification = BookingNotification(
                    id: booking.id,
                    dateComponents: dateComponents
                )
                self.notificationManager.scheduleNotification(
                    for: notification,
                    type: .booking,
                    userOffset: self.preferenceService.getNotificationOffset(),
                    completion: { result in
                        switch result {
                        case .success(let success):
                            AppLogger.shared.debug("Scheduled \(success) notification")
                        case .failure(let failure):
                            AppLogger.shared.debug("Failed : \(failure)")
                        }
                    })
            } else {
                AppLogger.shared.critical("Failed to retrieve date components for booking")
            }
        }
    }
    
    fileprivate func registerAutoSignup(
        tries: Int = 0,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        AppLogger.shared.debug("Automatically signing up for exams")
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.registerAllEvents(schoolId: String(schoolId))
                    let _ = networkManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { (result: Result<Response.KronoxEventRegistration?, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let eventRegistrations):
                                if let eventRegistrations = eventRegistrations {
                                    AppLogger.shared.debug("Successful registrations: \(String(describing: eventRegistrations.successfulRegistrations?.count))")
                                    AppLogger.shared.debug("Failed registrations: \(String(describing: eventRegistrations.failedRegistrations?.count))")
                                    completion(.success(()))
                                }
                            case .failure(let error):
                                AppLogger.shared.critical("Failed to automatically sign up for exams: \(error)")
                                completion(.failure(.generic(reason: "\(error)")))
                            }
                        }
                    })
                case .failure(let error):
                    AppLogger.shared.critical("Could not log in to register for available events")
                    completion(.failure(.generic(reason: "\(error)")))
                }
            })
    }
    
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
                AppLogger.shared.debug("Attempting auto login ...")
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
    
    fileprivate func cancelDataTaskIfTabChanged(dataTask: URLSessionDataTask?) {
        let currentSelectedTab = AppController.shared.selectedAppTab
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1)) {
            if AppController.shared.selectedAppTab != currentSelectedTab {
                DispatchQueue.main.async {
                    // selected app tab has changed, cancel the dataTask
                    AppLogger.shared.debug("Cancelling task due to tab change")
                    dataTask?.cancel()
                }
            }
        }
    }


}
