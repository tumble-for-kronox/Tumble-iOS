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

enum NetworkResponse {
    case success
    case error
}


/// ViewModel for the account page of the app.
/// It handles the signing in of users, registering and unregistering
/// for KronoX events, and booking and unbooking of resources.
@MainActor final class AccountViewModel: ObservableObject {
    
    @Inject var userController: UserController
    @Inject var networkManager: KronoxManager
    @Inject var preferenceService: PreferenceService
    
    @Published var school: School?
    @Published var status: AccountPageViewStatus = .initial
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var allResources: Response.KronoxResources? = nil
    @Published var userBookings: Response.KronoxUserBooking? = nil
    @Published var registeredEventSectionState: PageState = .loading
    @Published var bookingSectionState: PageState = .loading
    @Published var resourceBookingPageState: PageState = .loading
    @Published var eventBookingPageState: PageState = .loading
    @Published var error: Response.ErrorMessage? = nil
    
    private let jsonEncoder = JSONEncoder.shared
    
    init() {
        self.school = preferenceService.getDefaultSchool()
        if userController.autoSignup {
            self.registerAutoSignup()
        } else {
            AppLogger.shared.info("User has not enabled auto signup for events")
        }
    }
    
    func updateViewLocals() -> Void {
        self.school = preferenceService.getDefaultSchool()
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
                    self.networkManager.put(requestUrl, refreshToken: refreshToken, body: requestBody) {
                        (result: Result<Response.Empty, Response.ErrorMessage>) in
                        switch result {
                        case .success:
                            AppLogger.shared.info("Booked resource \(resourceId)")
                            completion(.success(()))
                        case .failure(let error):
                            AppLogger.shared.critical("Failed to book resource \(resourceId)")
                            completion(.failure(.internal(reason: "\(error)")))
                        }
                    }
                case .failure(let error):
                    AppLogger.shared.critical("\(error)")
                    completion(.failure(.internal(reason: "\(error)")))
                }
            }
        )
    }


    
    func getAllResourceData(tries: Int = 1, date: Date) -> Void {
        self.resourceBookingPageState = .loading
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.allResources(schoolId: String(schoolId), date: date)
                    self.networkManager.get(request, refreshToken: refreshToken,
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
    
    
    /// Retrieve user events for resource section
    func getUserEventsForSection(tries: Int = 1) {
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
                    networkManager.get(request, refreshToken: refreshToken,
                    then: { [unowned self] (result: Result<Response.KronoxCompleteUserEvent?, Response.ErrorMessage>) in
                        switch result {
                        case .success(let events):
                            DispatchQueue.main.async {
                                self.completeUserEvent = events
                                self.registeredEventSectionState = .loaded
                            }
                        case .failure(let failure):
                            AppLogger.shared.info("\(failure)")
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
                    networkManager.get(request, refreshToken: refreshToken,
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
                case .failure(_):
                    DispatchQueue.main.async {
                        self.eventBookingPageState = .error
                    }
                }
            })
    }
    
    func getUserBookingsForSection(tries: Int = 1) {
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
                    networkManager.get(request, refreshToken: refreshToken,
                       then: { [unowned self] (result: Result<Response.KronoxUserBooking?, Response.ErrorMessage>) in
                        switch result {
                        case .success(let bookings):
                            DispatchQueue.main.async {
                                self.bookingSectionState = .loaded
                                self.userBookings = bookings
                            }
                        case .failure(let failure):
                            AppLogger.shared.info("\(failure)")
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
    
    func registerForEvent(tries: Int = 1, eventId: String) {
        self.eventBookingPageState = .loading
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.registerEvent(eventId: eventId, schoolId: String(schoolId))
                    networkManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { [unowned self] (result: Result<Response.HTTPResponse?, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                self.getUserEventsForPage()
                            case .failure:
                                self.eventBookingPageState = .error
                            }
                        }
                    })
                case .failure:
                    DispatchQueue.main.async {
                        self.eventBookingPageState = .error
                    }
                }
            })
    }
    
    func unregisterForEvent(tries: Int = 1, eventId: String) {
        self.eventBookingPageState = .loading
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(schoolId))
                    networkManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { [unowned self] (result: Result<Response.HTTPResponse?, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                self.getUserEventsForPage()
                            case .failure(_):
                                self.eventBookingPageState = .error
                            }
                        }
                    })
                case .failure:
                    DispatchQueue.main.async {
                        self.eventBookingPageState = .error
                    }
                }
            })
    }
    
    func toggleAutoSignup(value: Bool) {
        userController.autoSignup = value
        if value {
            registerAutoSignup()
        }
    }
}


extension AccountViewModel {
    fileprivate func registerAutoSignup(tries: Int = 1) {
        authenticateAndExecute(
            school: school,
            refreshToken: userController.refreshToken,
            execute: { [unowned self] result in
                switch result {
                case .success((let schoolId, let refreshToken)):
                    let request = Endpoint.registerAllEvents(schoolId: String(schoolId))
                    networkManager.put(request, refreshToken: refreshToken, body: Request.Empty(),
                       then: { (result: Result<Response.KronoxEventRegistration?, Response.ErrorMessage>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let eventRegistrations):
                                if let eventRegistrations = eventRegistrations {
                                    AppLogger.shared.info("Successful registrations: \(String(describing: eventRegistrations.successfulRegistrations?.count))")
                                    AppLogger.shared.info("Failed registrations: \(String(describing: eventRegistrations.failedRegistrations?.count))")
                                }
                            case .failure(let failure):
                                AppLogger.shared.info("\(failure)")
                            }
                        }
                    })
                case .failure:
                    AppLogger.shared.info("Could not log in to register for available events")
                }
            })
    }
    
    /// Wrapper function that is meant to be used on functions
    /// that require authentication to be active before processing
    fileprivate func authenticateAndExecute(
        tries: Int = 1,
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
