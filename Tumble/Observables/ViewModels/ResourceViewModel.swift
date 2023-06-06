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
    
    func getUserEventsForPage() async {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.eventBookingPageState = .loading
        }
        
        do {
            let request = Endpoint.userEvents(schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                return
            }
            let events: Response.KronoxCompleteUserEvent?
                = try await kronoxManager.get(request, refreshToken: refreshToken.value)
            AppLogger.shared.debug("Successfully loaded events")
            DispatchQueue.main.async {
                self.completeUserEvent = events
                self.eventBookingPageState = .loaded
            }
        } catch (let error) {
            AppLogger.shared.debug("\(error)")
            DispatchQueue.main.async {
                self.eventBookingPageState = .error
            }
        }
    }
    
    func registerForEvent(eventId: String) async {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.eventBookingPageState = .loading
        }
        
        do {
            let request = Endpoint.registerEvent(eventId: eventId, schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                return
            }
            let _ : Response.Empty
                = try await kronoxManager.put(
                    request,
                    refreshToken: refreshToken.value,
                    body: Request.Empty())
        } catch (let error) {
            AppLogger.shared.debug("\(error)")
        }
    }
    
    func unregisterForEvent(eventId: String) async {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.eventBookingPageState = .loading
        }
        
        do {
            let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                return
            }
            let _ : Response.Empty = try await kronoxManager.put(
                request,
                refreshToken: refreshToken.value,
                body: Request.Empty())
            
        } catch (let error) {
            AppLogger.shared.debug("\(error)")
            DispatchQueue.main.async {
                self.eventBookingPageState = .error
            }
        }
    }
    
    func getAllResourceData(date: Date) async {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.resourceBookingPageState = .loading
        }
        
        do {
            let request = Endpoint.allResources(schoolId: String(authSchoolId), date: date)
            guard let refreshToken = userController.refreshToken else {
                return
            }
            let resources: Response.KronoxResources? = try await kronoxManager.get(
                request, refreshToken: refreshToken.value)
            DispatchQueue.main.async {
                self.allResources = resources
                self.resourceBookingPageState = .loaded
            }
        } catch (let error) {
            AppLogger.shared.debug("\(error)")
            DispatchQueue.main.async {
                self.resourceBookingPageState = .error
            }
        }
    }
    
    func confirmResource(resourceId: String, bookingId: String) async {
        do {
            let request = Endpoint.confirmResource(schoolId: String(authSchoolId))
            let requestBody = Request.ConfirmKronoxResource(
                resourceId: resourceId,
                bookingId: bookingId
            )
            guard let refreshToken = userController.refreshToken else {
                return
            }
            let _ : Response.Empty = try await kronoxManager.put(
                request, refreshToken: refreshToken.value, body: requestBody)
        } catch (let error) {
            AppLogger.shared.critical("Failed to confirm resource: \(error)")
        }
    }
    
    func bookResource(
        resourceId: String,
        date: Date,
        availabilityValue: Response.AvailabilityValue
    ) async -> Bool {
        do {
            let request = Endpoint.bookResource(schoolId: String(authSchoolId))
            let requestBody = Request.BookKronoxResource(
                resourceId: resourceId,
                date: isoDateFormatterFract.string(from: date),
                slot: availabilityValue
            )
            guard let refreshToken = userController.refreshToken else {
                return false
            }
            let _ : Response.KronoxUserBookingElement? = try await kronoxManager.put(
                request, refreshToken: refreshToken.value, body: requestBody)
        } catch (let error) {
            AppLogger.shared.critical("Failed to book resource: \(error)")
            return false
        }
        return true
    }
    
    func unbookResource(bookingId: String) async -> Bool {
        do {
            let request: Endpoint = .unbookResource(schoolId: String(authSchoolId), bookingId: bookingId)
            guard let refreshToken = userController.refreshToken else {
                return false
            }
            let _ : Response.Empty = try await kronoxManager.put(
                request, refreshToken: refreshToken.value, body: Request.Empty())
            AppLogger.shared.debug("Unbooked resource")
            self.notificationManager.cancelNotification(for: bookingId)
        } catch (let error) {
            AppLogger.shared.critical("Failed to unbook resource: \(bookingId)\nError: \(error)")
            return false
        }
        return true
    }
}
