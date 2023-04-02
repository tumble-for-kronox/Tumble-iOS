import Foundation

/// ViewModel for the account page of the app.
/// It handles the signing in of users, registering and unregistering
/// for KronoX events, and booking and unbooking of resources.
@MainActor final class AccountViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var userController: UserController
    @Inject var networkManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    @Inject var schoolManager: SchoolManager
    
    @Published var school: School?
    @Published var status: AccountViewStatus = .initial
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
    
    init() {
        self.school = preferenceService.getDefaultSchoolName(schools: schoolManager.getSchools())
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
    }
    
    func updateViewLocals() -> Void {
        self.school = preferenceService.getDefaultSchoolName(schools: schoolManager.getSchools())
    }

    func removeUserBooking(where id: String) -> Void {
        DispatchQueue.main.async {
            self.userBookings?.removeAll {
                $0.id == id
            }
        }
    }
    
    func userAuthenticatedAndSignedIn() -> Bool {
        return userController.authStatus == .authorized || userController.refreshToken != nil
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
    
    func checkNotificationsForUserBookings(bookings: Response.KronoxUserBookings? = nil) -> Void {
        AppLogger.shared.debug("Checking for notifications to set for user booked resources ...")
        
        if let userBookings = bookings {
            self.scheduleBookingNotifications(for: userBookings)
            return
        }
        
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.userBookings(schoolId: String(schoolId))
                    self.resourceSectionDataTask = self.networkManager.get(request, refreshToken: refreshToken,
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
