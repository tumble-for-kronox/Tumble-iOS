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
    @Inject var networkManager: NetworkManager
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
    
    init() {
        self.school = preferenceService.getDefaultSchool()
        if userController.autoSignup {
            self.registerAutoSignup()
        } else {
            AppLogger.shared.debug("User has not enabled auto signup for events")
        }
        self.getUserBookingsForSection()
        self.getUserEventsForSection()
    }
    
    func updateViewLocals() -> Void {
        self.school = preferenceService.getDefaultSchool()
    }

    
    func login(username: String, password: String, createToast: @escaping (Bool) -> Void ) -> Void {
        self.status = .loading
        self.userController.logIn(
            username: username,
            password: password,
            completion: { [weak self] success in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.status = .initial
                }
                self.getUserEventsForSection()
                self.getUserBookingsForSection()
                createToast(success)
            })
    }
    
    func getAllResourceData(tries: Int = 1, date: Date) -> Void {
        DispatchQueue.main.async {
            self.resourceBookingPageState = .loading
        }
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getAllResourceData(tries: tries + 1, date: date)
                })
            }
            DispatchQueue.main.async {
                self.resourceBookingPageState = .error
            }
            return
        }
        let request = Endpoint.allResources(sessionToken: sessionToken.value, schoolId: String(school.id), date: date)
        self.networkManager.get(request,
        then: { [weak self] (result: Result<Response.KronoxResources, Response.ErrorMessage>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let resources):
                    self.allResources = resources
                    self.resourceBookingPageState = .loaded
                case .failure(let error):
                    AppLogger.shared.debug("\(error)")
                    self.resourceBookingPageState = .error
                    self.error = error
                }
            }
        })
    }
    
    
    /// Retrieve user events for resource section
    func getUserEventsForSection(tries: Int = 1) {
        DispatchQueue.main.async {
            self.registeredEventSectionState = .loading
        }
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getUserEventsForSection(tries: tries + 1)
                })
            }
            DispatchQueue.main.async {
                self.registeredEventSectionState = .error
            }
            return
        } 
        let request = Endpoint.userEvents(sessionToken: sessionToken.value, schoolId: String(school.id))
        networkManager.get(request,
        then: { [weak self] (result: Result<Response.KronoxCompleteUserEvent, Response.ErrorMessage>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.completeUserEvent = events
                    self.registeredEventSectionState = .loaded
                case .failure(let failure):
                    AppLogger.shared.debug("\(failure)")
                    self.registeredEventSectionState = .error
                }
            }
        })
    }
    
    func getUserEventsForPage(tries: Int = 0, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.eventBookingPageState = .loading
        }
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getUserEventsForPage(tries: tries + 1)
                })
            }
            DispatchQueue.main.async {
                self.eventBookingPageState = .error
            }
            return
        }
        let request = Endpoint.userEvents(sessionToken: sessionToken.value, schoolId: String(school.id))
        networkManager.get(request,
        then: { [weak self] (result: Result<Response.KronoxCompleteUserEvent, Response.ErrorMessage>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.completeUserEvent = events
                    AppLogger.shared.debug("Successfully loaded events")
                    self.eventBookingPageState = .loaded
                case .failure(let failure):
                    AppLogger.shared.debug("\(failure)")
                    self.eventBookingPageState = .error
                }
            }
        })
    }
    
    func getUserBookingsForSection(tries: Int = 1) {
        DispatchQueue.main.async {
            self.bookingSectionState = .loading
        }
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getUserBookingsForSection(tries: tries + 1)
                })
            }
            DispatchQueue.main.async {
                self.bookingSectionState = .error
                // If this fails then we want to set the
                // user events section to error as well, as that request
                // does not necessarily fail but will be empty
                self.registeredEventSectionState = .error
                self.completeUserEvent = nil
            }
            return
        }
        let request = Endpoint.userBookings(schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.get(request, then: { [weak self] (result: Result<Response.KronoxUserBooking, Response.ErrorMessage>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let bookings):
                    self.bookingSectionState = .loaded
                    self.userBookings = bookings
                case .failure(let failure):
                    AppLogger.shared.debug("\(failure)")
                    self.bookingSectionState = .error
                }
            }
        })
    }
    
    func getUserBookingsForPage(tries: Int = 1) {
        DispatchQueue.main.async {
            self.resourceBookingPageState = .loading
        }
        guard let school = school,
              let sessionToken = userController.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.getUserBookingsForPage(tries: tries + 1)
                })
            }
            DispatchQueue.main.async {
                self.resourceBookingPageState = .error
            }
            return
        }
        let request = Endpoint.userBookings(schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.get(request, then: { [weak self] (result: Result<Response.KronoxUserBooking, Response.ErrorMessage>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.getUserBookingsForPage()
                case .failure(let failure):
                    AppLogger.shared.debug("\(failure)")
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
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.registerForEvent(tries: tries + 1, eventId: eventId)
                })
            }
            self.eventBookingPageState = .error
            return
        }
        let request = Endpoint.registerEvent(eventId: eventId, schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.put(request, then: { [weak self] (result: Result<Response.HTTPResponse, Response.ErrorMessage>) in
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
                AppLogger.shared.debug("Attempting auto login ...")
                userController.autoLogin(completion: {
                    self.unregisterForEvent(tries: tries + 1, eventId: eventId)
                })
            }
            self.eventBookingPageState = .error
            return
        }
        let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.put(request, then: { [weak self] (result: Result<Response.HTTPResponse, Response.ErrorMessage>) in
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
                AppLogger.shared.debug("Attempting auto log in ...")
                userController.autoLogin(completion: {
                    self.registerAutoSignup(tries: tries + 1)
                })
            }
            AppLogger.shared.debug("Could not log in in order to get new session token")
            return
        }
        let request = Endpoint.registerAllEvents(schoolId: String(school.id), sessionToken: sessionToken.value)
        networkManager.put(request, then: { (result: Result<Response.KronoxEventRegistration, Response.ErrorMessage>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let eventRegistrations):
                    AppLogger.shared.debug("\(eventRegistrations)")
                    AppLogger.shared.debug("Successful registrations: \(String(describing: eventRegistrations.successfulRegistrations?.count))")
                    AppLogger.shared.debug("Failed registrations: \(String(describing: eventRegistrations.failedRegistrations?.count))")
                case .failure(let failure):
                    AppLogger.shared.debug("\(failure)")
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
