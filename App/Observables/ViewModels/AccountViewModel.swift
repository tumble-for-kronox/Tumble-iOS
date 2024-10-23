//
//  AccountViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/27/22.
//

import Combine
import Foundation

/// ViewModel for the account page of the app.
/// It handles the signing in of users, registering and unregistering
/// for KronoX events, and booking and unbooking of resources.
final class AccountViewModel: ObservableObject {
    let viewModelFactory: ViewModelFactory = .shared
    let userController: UserController = .shared
    
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceManager: PreferenceManager
    @Inject var schoolManager: SchoolManager
    
    @Published var authStatus: AuthStatus = .unAuthorized
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var userBookings: Response.KronoxUserBookings? = nil
    @Published var registeredEventSectionState: GenericPageStatus = .loading
    @Published var bookingSectionState: GenericPageStatus = .loading
    @Published var error: Response.ErrorMessage? = nil
    @Published var resourceDetailsSheetModel: ResourceDetailSheetModel? = nil
    @Published var examDetailSheetModel: ExamDetailSheetModel? = nil
    @Published var authSchoolId: Int = -1
    @Published var autoSignupEnabled: Bool = false
    @Published var registeredForExams: Bool = false
    
    private var resourceSectionDataTask: URLSessionDataTask? = nil
    private var eventSectionDataTask: URLSessionDataTask? = nil
    private let popupFactory: PopupFactory = PopupFactory.shared
    
    var userDisplayName: String? {
        return userController.user?.name
    }
    
    var username: String? {
        return userController.user?.username
    }
    
    var schoolName: String {
        return schools.first(where: { $0.id == authSchoolId})?.name ?? ""
    }
    
    /// AccountViewModel is responsible for instantiating
    /// the viewmodel used in its child views it navigates to
    lazy var resourceViewModel: ResourceViewModel = viewModelFactory.makeViewModelResource()
    lazy var schools: [School] = schoolManager.getSchools()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupPublishers()
        addNotificationObserver()
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(handleResourceBooked(_:)),
                name: .resourceBooked,
                object: nil
            )
    }
    
    @objc private func handleResourceBooked(_ notification: Notification) {
        Task { await self.getUserBookingsForSection() }
    }
    
    private func setupPublishers() {
        let authStatusPublisher = userController.$authStatus.receive(on: RunLoop.main)
        let authSchoolIdPublisher = preferenceManager.$authSchoolId.receive(on: RunLoop.main)
        let autoSignupPublisher = preferenceManager.$autoSignup.receive(on: RunLoop.main)

        Publishers.CombineLatest3(authStatusPublisher, authSchoolIdPublisher, autoSignupPublisher)
            .sink { [weak self] authStatus, authSchoolId, autoSignupEnabled in
                guard let self else { return }
                
                DispatchQueue.main.async {
                    self.authStatus = authStatus
                    self.authSchoolId = authSchoolId
                    self.autoSignupEnabled = autoSignupEnabled

                    if authStatus == .authorized && !self.registeredForExams && self.autoSignupEnabled {
                        Task.detached(priority: .userInitiated) {
                            AppLogger.shared.debug("Auto signup is \(autoSignupEnabled), registering for exams")
                            await self.registerAutoSignup()
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }

    
    /// Removes a users resource booking in the locally cached
    /// version. The actual network request is done in `ResourceViewModel`
    func removeCachedUserBooking(where id: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.notificationManager.cancelNotification(for: id)
            self.userBookings?.removeAll { $0.id == id }
        }
    }
    
    /// Caching approach to avoid a network call after user
    /// unregisters for an event in account page, and instead modify it in place,
    /// since network errors can occur.
    func removeUserEvent(for id: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            if var mutRegisteredEvents = self.completeUserEvent?.registeredEvents,
               var mutUnregisteredEvents = self.completeUserEvent?.unregisteredEvents
            {
                /// Find subject in current struct
                let eventRemoved = mutRegisteredEvents.first {
                    $0.eventId == id
                }
                /// Add to new array
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
                        unregisteredEvents: mutUnregisteredEvents
                    )
                }
            }
        }
    }
    
    /// Logs current user out, delegating work to
    /// `UserController`. Also cancels any created notifications
    /// that were done when any bookings were created.
    func logOut() async {
        do {
            try await userController.logOut()
            await notificationManager.cancelNotifications(with: "Booking")
        } catch {
            AppLogger.shared.error("Failed to log out user: \(error)")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                PopupToast(popup: self.popupFactory.logOutFailed()).showAndStack()
            }
        }
    }
    
    /// Retrieves user events for resource section in `UserOverview`
    func getUserEventsForSection() async {
        DispatchQueue.main.async { [weak self] in
            self?.registeredEventSectionState = .loading
        }
        
        do {
            let request = Endpoint.userEvents(schoolId: String(authSchoolId))
            let events: Response.KronoxCompleteUserEvent? = try await kronoxManager.get(
                request, refreshToken: userController.refreshToken?.value, sessionDetails: userController.sessionDetails?.value)
            DispatchQueue.main.async { [weak self] in
                self?.completeUserEvent = events
                self?.registeredEventSectionState = .loaded
            }
        } catch {
            AppLogger.shared.error("Could not get user events: \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.registeredEventSectionState = .error
            }
        }
    }
    
    /// Retrieves user bookings for resource section in `UserOverview`
    func getUserBookingsForSection() async {
        DispatchQueue.main.async {
            self.bookingSectionState = .loading
        }
        
        do {
            let request = Endpoint.userBookings(schoolId: String(authSchoolId))
            let bookings: Response.KronoxUserBookings = try await kronoxManager.get(
                request, refreshToken: userController.refreshToken?.value, sessionDetails: userController.sessionDetails?.value)
            DispatchQueue.main.async {
                self.bookingSectionState = .loaded
                self.userBookings = bookings
            }
            await self.checkNotificationsForUserBookings(bookings: bookings)
        } catch {
            AppLogger.shared.debug("\(error)")
            DispatchQueue.main.async {
                self.bookingSectionState = .error
            }
        }
    }
    
    /// Removes a registered event from the users account,
    /// as well as the locally stored object
    func unregisterForEvent(eventId: String) async {
        do {
            let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(authSchoolId))
            let _ : Response.Empty = try await kronoxManager.put(
                request,
                refreshToken: userController.refreshToken?.value,
                sessionDetails: userController.sessionDetails?.value, body: NetworkRequest.Empty())
            self.removeUserEvent(for: eventId)
            DispatchQueue.main.async {
                self.registeredEventSectionState = .loaded
            }
        } catch {
            AppLogger.shared.error("Failed to unregister from event: \(error)")
            // TODO: Add toast
            DispatchQueue.main.async {
                self.registeredEventSectionState = .error
            }
        }
    }
    
    /// Registers the user for automatic event/exam signup,
    /// and attempts to sign up for any currently available exams/events
    func toggleAutoSignup(value: Bool) {
        preferenceManager.autoSignup.toggle()
        if value && !self.registeredForExams {
            Task {
                await registerAutoSignup()
                await getUserEventsForSection()
            }
        }
    }
    
    /// Decides if there are any user bookings for the current user, and if so attempts
    /// to schedule any confirmation notifications for those bookings
    func checkNotificationsForUserBookings(bookings: Response.KronoxUserBookings? = nil) async {
        AppLogger.shared.debug("Checking for notifications to set for user booked resources ...")
        if let userBookings = bookings {
            Task {
                await scheduleBookingNotifications(for: userBookings)
            }
            return
        }
        
        do {
            let request = Endpoint.userBookings(schoolId: String(authSchoolId))
            let bookings: Response.KronoxUserBookings = try await kronoxManager.get(
                request, refreshToken: userController.refreshToken?.value, sessionDetails: userController.sessionDetails?.value)
            Task {
                await self.scheduleBookingNotifications(for: bookings)
            }
        } catch {
            AppLogger.shared.debug("\(error)")
            DispatchQueue.main.async {
                self.bookingSectionState = .error
            }
        }
    }
    
    /// Schedules notifications for the given bookings
    func scheduleBookingNotifications(for bookings: Response.KronoxUserBookings) async {
        for booking in bookings {
            if let notification = notificationManager.createNotificationFromBooking(booking: booking) {
                do {
                    try await notificationManager.scheduleNotification(
                        for: notification,
                        type: .booking,
                        userOffset: preferenceManager.notificationOffset.rawValue
                    )
                    AppLogger.shared.debug("Scheduled one notification with id: \(notification.id)")
                } catch let failure {
                    AppLogger.shared.debug("Failed: \(failure)")
                }
            } else {
                AppLogger.shared.error("Failed to retrieve date components for booking")
            }
        }
    }

    /// Registers for any available events through auto signup
    func registerAutoSignup() async {
        AppLogger.shared.debug("Attempting to automatically sign up for exams")
        do {
            let request = Endpoint.registerAllEvents(schoolId: String(authSchoolId))
            let _: Response.KronoxEventRegistration?
            = try await kronoxManager.put(
                request, refreshToken: userController.refreshToken?.value,
                sessionDetails: userController.sessionDetails?.value, body: NetworkRequest.Empty())
            self.registeredForExams = true
        } catch {
            AppLogger.shared.error("Failed to sign up for exams: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        cancellables.forEach { $0.cancel() }
    }
    
}
