//
//  UserDefaultsService.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import Combine

class PreferenceManager: ObservableObject {
        
    @Published var userOnboarded: Bool
    @Published var authSchoolId: Int
    @Published var appearance: String
    @Published var autoSignup: Bool
    @Published var notificationOffset: Int
    @Published var language: String
    @Published var viewTypeIndex: Int
    @Published var lastUpdated: Date
    @Published var firstOpen: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        onboardingPreference: OnboardingPreference = OnboardingPreference(),
        authSchoolPreference: AuthSchoolPreference = AuthSchoolPreference(),
        appearancePreference: AppearancePreference = AppearancePreference(),
        autoSignupPreference: AutoSignupPreference = AutoSignupPreference(),
        notificationOffsetPreference: NotificationOffsetPreference = NotificationOffsetPreference(),
        languagePreference: LanguagePreference = LanguagePreference(),
        viewTypePreference: ViewTypeIndexPreference = ViewTypeIndexPreference(),
        lastUpdatedPreference: LastUpdatedPreference = LastUpdatedPreference(),
        firstOpenPreference: FirstOpenPreference = FirstOpenPreference()
    ) {
        self.userOnboarded = onboardingPreference.get()
        self.authSchoolId = authSchoolPreference.get()
        self.appearance = appearancePreference.get()
        self.autoSignup = autoSignupPreference.get()
        self.notificationOffset = notificationOffsetPreference.get()
        self.language = languagePreference.get()
        self.viewTypeIndex = viewTypePreference.get()
        self.lastUpdated = lastUpdatedPreference.get()
        self.firstOpen = firstOpenPreference.get()

        bindPreference($userOnboarded, initialValue: userOnboarded, to: onboardingPreference)
        bindPreference($authSchoolId, initialValue: authSchoolId, to: authSchoolPreference)
        bindPreference($appearance, initialValue: appearance, to: appearancePreference)
        bindPreference($autoSignup, initialValue: autoSignup, to: autoSignupPreference)
        bindPreference($notificationOffset, initialValue: notificationOffset, to: notificationOffsetPreference)
        bindPreference($language, initialValue: language, to: languagePreference)
        bindPreference($viewTypeIndex, initialValue: viewTypeIndex, to: viewTypePreference)
        bindPreference($lastUpdated, initialValue: lastUpdated, to: lastUpdatedPreference)
        bindPreference($firstOpen, initialValue: firstOpen, to: firstOpenPreference)
    }
    
    private func bindPreference<T, Preference: PreferenceStorable>(
        _ publisher: Published<T>.Publisher, initialValue: T, to preference: Preference)
        where Preference.ValueType == T {
        preference.set(initialValue)
        publisher
            .sink { value in
                preference.set(value)
            }
            .store(in: &cancellables)
    }

}
