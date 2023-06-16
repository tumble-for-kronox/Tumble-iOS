//
//  LoginViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 6/16/23.
//

import SwiftUI
import Combine

final class LoginViewModel: ObservableObject {
    @Inject private var preferenceService: PreferenceService
    @Inject private var userController: UserController
    @Inject private var schoolManager: SchoolManager
    
    @Published var attemptingLogin: Bool = false
    @Published var authSchoolId: Int = -1
    
    let popupFactory: PopupFactory = .shared
    lazy var schools: [School] = schoolManager.getSchools()
    var cancellable: AnyCancellable? = nil
    
    init() {
        setupDataPublishers()
    }
    
    private func setupDataPublishers() {
        let authSchoolIdPublisher = preferenceService.$authSchoolId.receive(on: RunLoop.main)
        cancellable = authSchoolIdPublisher
            .sink { [weak self] authSchoolId in
                self?.authSchoolId = authSchoolId
            }
    }
    
    func setDefaultAuthSchool(schoolId: Int) {
        preferenceService.setAuthSchool(id: schoolId)
    }
    
    func login(
        authSchoolId: Int,
        username: String,
        password: String
    ) async {
        defer {
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.attemptingLogin = false
                }
            }
        }
        do {
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.attemptingLogin = true
                }
            }
            try await userController.logIn(authSchoolId: authSchoolId, username: username, password: password)
            if let username = userController.user?.username {
                DispatchQueue.main.async { [weak self] in
                    AppController.shared.popup = self?.popupFactory.logInSuccess(as: username)
                }
            }
        } catch {
            AppLogger.shared.critical("Failed to log in user: \(error)")
            DispatchQueue.main.async { [weak self] in
                AppController.shared.popup = self?.popupFactory.logInFailed()
            }
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
}
