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

@MainActor final class AccountPageViewModel: ObservableObject {
    
    @Inject var userController: UserController
    @Inject var networkManager: NetworkManager
    @Inject var preferenceService: PreferenceService
    
    @Published var school: School?
    @Published var status: AccountPageViewStatus = .initial
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent?
    @Published var userBookings: Response.KronoxUserBooking?
    @Published var registeredEventSectionState: PageState = .loading
    @Published var bookingSectionState: PageState = .loading
    @Published var resourceBookingPageState: PageState = .loading
    @Published var eventBookingPageState: PageState = .loading
    
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
    
    /// Retrieve user events for resource section
    func getUserEventsForSection(tries: Int = 1) {
        self.registeredEventSectionState = .loading
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.info("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getUserEventsForSection(tries: tries + 1)
                })
            }
            self.registeredEventSectionState = .error
            return
        } 
        let request = Endpoint.userEvents(sessionToken: sessionToken.value, schoolId: String(school.id))
        networkManager.get(request, then: { [weak self] (result: Result<Response.KronoxCompleteUserEvent, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.registeredEventSectionState = .loaded
                    self.completeUserEvent = events
                case .failure(let failure):
                    AppLogger.shared.info("\(failure)")
                    self.registeredEventSectionState = .error
                }
            }
        })
    }
    
    func getUserEventsForPage(tries: Int = 0, completion: (() -> Void)? = nil) {
        self.eventBookingPageState = .loading
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.info("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getUserEventsForPage(tries: tries + 1)
                })
            }
            self.eventBookingPageState = .error
            return
        }
        let request = Endpoint.userEvents(sessionToken: sessionToken.value, schoolId: String(school.id))
        networkManager.get(request, then: { [weak self] (result: Result<Response.KronoxCompleteUserEvent, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.completeUserEvent = events
                    AppLogger.shared.info("Successfully loaded events")
                    self.eventBookingPageState = .loaded
                case .failure(let failure):
                    AppLogger.shared.info("\(failure)")
                    self.eventBookingPageState = .error
                }
            }
        })
    }
    
    func getUserBookingsForSection(tries: Int = 1) {
        self.bookingSectionState = .loading
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.info("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getUserBookingsForSection(tries: tries + 1)
                })
            }
            self.bookingSectionState = .error
            return
        }
        let request = Endpoint.userBookings(schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.get(request, then: { [weak self] (result: Result<Response.KronoxUserBooking, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let bookings):
                    self.bookingSectionState = .loaded
                    self.userBookings = bookings
                case .failure(let failure):
                    AppLogger.shared.info("\(failure)")
                    self.bookingSectionState = .error
                }
            }
        })
    }
    
    func getUserBookingsForPage(tries: Int = 1) {
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.info("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getUserBookingsForPage(tries: tries + 1)
                })
            }
            self.resourceBookingPageState = .error
            return
        }
        let request = Endpoint.userBookings(schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.get(request, then: { [weak self] (result: Result<Response.KronoxUserBooking, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.getUserBookingsForPage()
                case .failure(let failure):
                    AppLogger.shared.info("\(failure)")
                    self.resourceBookingPageState = .error
                }
            }
        })
    }
    
    func registerForEvent(tries: Int = 1, eventId: String) {
        self.eventBookingPageState = .loading
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.info("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.registerForEvent(tries: tries + 1, eventId: eventId)
                })
            }
            self.eventBookingPageState = .error
            return
        }
        let request = Endpoint.registerEvent(eventId: eventId, schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.put(request, then: { [weak self] (result: Result<Response.HTTPResponse, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.getUserEventsForPage()
                case .failure(_):
                    self.eventBookingPageState = .error
                }
            }
        })
    }
    
    func unregisterForEvent(tries: Int = 1, eventId: String) {
        self.eventBookingPageState = .loading
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.info("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.unregisterForEvent(tries: tries + 1, eventId: eventId)
                })
            }
            self.eventBookingPageState = .error
            return
        }
        let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.put(request, then: { [weak self] (result: Result<Response.HTTPResponse, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    AppLogger.shared.info("\(result)")
                    self.getUserEventsForPage()
                case .failure(_):
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
    
    fileprivate func registerAutoSignup(tries: Int = 1) {
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.info("Attempting auto log in ...")
                userController.autoLogin(completion: {
                    self.registerAutoSignup(tries: tries + 1)
                })
            }
            AppLogger.shared.info("Could not log in in order to get new session token")
            return
        }
        let request = Endpoint.registerAllEvents(schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.put(request, then: { (result: Result<Response.KronoxEventRegistration, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let eventRegistrations):
                    AppLogger.shared.info("\(eventRegistrations)")
                    AppLogger.shared.info("Successful registrations: \(eventRegistrations.successfulRegistrations?.count)")
                    AppLogger.shared.info("Failed registrations: \(eventRegistrations.failedRegistrations?.count)")
                case .failure(let failure):
                    AppLogger.shared.info("\(failure)")
                }
            }
        })
        
    }
    
    /// Executes if the user is attempting to fetch resources/events in either booking
    /// pages or the overview resource section and their sessiontoken/login has expired
    fileprivate func autoLoginIfNeeded(tries: Int, completion: @escaping (Bool) -> Void) {
        if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
            userController.autoLogin {
                completion(self.userController.sessionToken != nil && !self.userController.sessionToken!.isExpired())
            }
        } else {
            completion(false)
        }
    }
}
