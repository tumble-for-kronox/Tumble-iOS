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
    
    @Inject var userController: UserController
    @Inject var networkManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    
    @Published var school: School?
    @Published var status: AccountPageViewStatus = .initial
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var allResources: Response.KronoxResources? = nil
    @Published var userBookings: Response.KronoxUserBookings? = nil
    @Published var registeredEventSectionState: PageState = .loading
    @Published var bookingSectionState: PageState = .loading
    @Published var resourceBookingPageState: PageState = .loading
    @Published var eventBookingPageState: PageState = .loading
    @Published var error: Response.ErrorMessage? = nil
    @Published var resourceDetailsSheetModel: ResourceDetailSheetModel? = nil
    @Published var examDetailSheetModel: ExamDetailSheetModel? = nil
    
    private let jsonEncoder = JSONEncoder.shared
    private var resourceSectionDataTask: URLSessionDataTask? = nil
    private var eventSectionDataTask: URLSessionDataTask? = nil
    
    init() {
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
    
    func createNotification(id: String) -> Void {
        // Schedule notification for resource booking confirmation
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
                    let _ = self.networkManager.put(requestUrl, refreshToken: refreshToken, body: requestBody) {
                        (result: Result<Response.Empty, Response.ErrorMessage>) in
                        switch result {
                        case .success:
                            AppLogger.shared.info("Booked resource \(resourceId)")
                            completion(.success(()))
                        case .failure(let error):
                            AppLogger.shared.critical("Failed to book resource: \(resourceId)")
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

    
    func getAllResourceData(tries: Int = 1, date: Date) -> Void {
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
                    self.eventSectionDataTask = networkManager.get(request, refreshToken: refreshToken,
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
        cancelDataTaskIfTabChanged(dataTask: eventSectionDataTask)
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
                    self.resourceSectionDataTask = networkManager.get(request, refreshToken: refreshToken,
                       then: { [weak self] (result: Result<Response.KronoxUserBookings?, Response.ErrorMessage>) in
                        guard let self = self else { return }
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
        cancelDataTaskIfTabChanged(dataTask: resourceSectionDataTask)
    }
    
    func registerForEvent(
        tries: Int = 1,
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
        tries: Int = 1,
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
}


extension AccountViewModel {
    fileprivate func registerAutoSignup(
        tries: Int = 1,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        AppLogger.shared.info("Automatically signing up for exams")
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
                                    AppLogger.shared.info("Successful registrations: \(String(describing: eventRegistrations.successfulRegistrations?.count))")
                                    AppLogger.shared.info("Failed registrations: \(String(describing: eventRegistrations.failedRegistrations?.count))")
                                    completion(.success(()))
                                }
                            case .failure(let error):
                                AppLogger.shared.info("Failed to automatically sign up for exams: \(error)")
                                completion(.failure(.generic(reason: "\(error)")))
                            }
                        }
                    })
                case .failure(let error):
                    AppLogger.shared.info("Could not log in to register for available events")
                    completion(.failure(.generic(reason: "\(error)")))
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
            if tries <= NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
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
    
    fileprivate func cancelDataTaskIfTabChanged(dataTask: URLSessionDataTask?) {
        let currentSelectedTab = AppController.shared.selectedAppTab
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1)) {
            if AppController.shared.selectedAppTab != currentSelectedTab {
                DispatchQueue.main.async {
                    // selected app tab has changed, cancel the dataTask
                    AppLogger.shared.info("Cancelling task due to tab change")
                    dataTask?.cancel()
                }
            }
        }
    }


}
