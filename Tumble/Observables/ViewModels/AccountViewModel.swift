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
    
    @Inject var userController: UserController
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    @Inject var schoolManager: SchoolManager
    
    @Published var schoolName: String = ""
    @Published var authStatus: AuthStatus = .unAuthorized
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var userBookings: Response.KronoxUserBookings? = nil
    @Published var registeredEventSectionState: GenericPageStatus = .loading
    @Published var bookingSectionState: GenericPageStatus = .loading
    @Published var error: Response.ErrorMessage? = nil
    @Published var resourceDetailsSheetModel: ResourceDetailSheetModel? = nil
    @Published var examDetailSheetModel: ExamDetailSheetModel? = nil
    
    private var resourceSectionDataTask: URLSessionDataTask? = nil
    private var eventSectionDataTask: URLSessionDataTask? = nil
    private let popupFactory: PopupFactory = PopupFactory.shared
    private lazy var authSchoolId: Int = preferenceService.authSchoolId
    
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
    private var cancellable: AnyCancellable? = nil
    
    init() {
        setupPublishers()
        schoolName = schoolManager.getSchools().first(where: { $0.id == authSchoolId})?.name ?? ""
        Task {
            if self.userController.autoSignup {
                await self.registerAutoSignup()
            }
        }
    }
    
    private func setupPublishers() {
        let authStatusPublisher = userController.$authStatus.receive(on: RunLoop.main)
        cancellable = authStatusPublisher.sink { [weak self] authStatus in
            DispatchQueue.main.async {
                self?.authStatus = authStatus
            }
        }
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
                        availableEvents: self.completeUserEvent?.availableEvents,
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
            AppLogger.shared.critical("Failed to log out user: \(error)")
            DispatchQueue.main.async { [weak self] in
                AppController.shared.popup = self?.popupFactory.logOutFailed()
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
            guard let refreshToken = userController.refreshToken else {
                DispatchQueue.main.async { [weak self] in
                    self?.registeredEventSectionState = .error
                }
                return
            }
            let events: Response.KronoxCompleteUserEvent? = try await kronoxManager.get(request, refreshToken: refreshToken.value)
            DispatchQueue.main.async { [weak self] in
                self?.completeUserEvent = events
                self?.registeredEventSectionState = .loaded
            }
        } catch {
            AppLogger.shared.critical("Could not get user events: \(error)")
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
            guard let refreshToken = userController.refreshToken else {
                DispatchQueue.main.async {
                    self.bookingSectionState = .error
                }
                return
            }
            let bookings: Response.KronoxUserBookings = try await kronoxManager.get(request, refreshToken: refreshToken.value)
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
            guard let refreshToken = userController.refreshToken else {
                DispatchQueue.main.async {
                    self.registeredEventSectionState = .error
                }
                return
            }
            let _ : Response.Empty = try await kronoxManager.put(request, refreshToken: refreshToken.value, body: Request.Empty())
            self.removeUserEvent(for: eventId)
            DispatchQueue.main.async {
                self.registeredEventSectionState = .loaded
            }
        } catch {
            AppLogger.shared.critical("Failed to unregister from event: \(error)")
            // TODO: Add toast
            DispatchQueue.main.async {
                self.registeredEventSectionState = .error
            }
        }
    }
    
    /// Registers the user for automatic event/exam signup,
    /// and attempts to sign up for any currently available exams/events
    func toggleAutoSignup(value: Bool) {
        userController.autoSignup = value
        if value {
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
            guard let refreshToken = userController.refreshToken else {
                DispatchQueue.main.async {
                    self.bookingSectionState = .error
                }
                return
            }
            let bookings: Response.KronoxUserBookings = try await kronoxManager.get(request, refreshToken: refreshToken.value)
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
                        userOffset: preferenceService.getNotificationOffset()
                    )
                    AppLogger.shared.debug("Scheduled one notification with id: \(notification.id)")
                } catch let failure {
                    AppLogger.shared.debug("Failed: \(failure)")
                }
            } else {
                AppLogger.shared.critical("Failed to retrieve date components for booking")
            }
        }
    }

    /// Registers for any available events through auto signup
    func registerAutoSignup() async {
        AppLogger.shared.debug("Attempting to automatically sign up for exams")
        do {
            let request = Endpoint.registerAllEvents(schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                AppController.shared.popup = PopupFactory.shared.genericError()
                return
            }
            let _: Response.KronoxEventRegistration?
                = try await kronoxManager.put(request, refreshToken: refreshToken.value, body: Request.Empty())
        } catch {
            AppLogger.shared.critical("Failed to sign up for exams: \(error)")
        }
    }
    
}
