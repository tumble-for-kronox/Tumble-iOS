//
//  UserDefaultsService.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import Combine

import Foundation
import Combine

class PreferenceManager: ObservableObject {
    
    @Published var userOnboarded: Bool
    @Published var authSchoolId: Int
    @Published var appearance: AppearanceType  // Using AppearanceType directly
    @Published var autoSignup: Bool
    @Published var notificationOffset: NotificationOffset  // Using NotificationOffset directly
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
        self.appearance = AppearanceType.fromRawValue(appearancePreference.get()) ?? .system  // Convert String to enum
        self.autoSignup = autoSignupPreference.get()
        self.notificationOffset = NotificationOffset(rawValue: notificationOffsetPreference.get()) ?? .hour  // Convert Int to enum
        self.language = languagePreference.get()
        self.viewTypeIndex = viewTypePreference.get()
        self.lastUpdated = lastUpdatedPreference.get()
        self.firstOpen = firstOpenPreference.get()

        // Bind preferences using enums
        bindPreference($userOnboarded, initialValue: userOnboarded, to: onboardingPreference)
        bindPreference($authSchoolId, initialValue: authSchoolId, to: authSchoolPreference)
        bindEnumPreference($appearance, initialValue: appearance, to: appearancePreference)  // Special handling for AppearanceType
        bindPreference($autoSignup, initialValue: autoSignup, to: autoSignupPreference)
        bindEnumPreference($notificationOffset, initialValue: notificationOffset, to: notificationOffsetPreference)  // Special handling for NotificationOffset
        bindPreference($language, initialValue: language, to: languagePreference)
        bindPreference($viewTypeIndex, initialValue: viewTypeIndex, to: viewTypePreference)
        bindPreference($lastUpdated, initialValue: lastUpdated, to: lastUpdatedPreference)
        bindPreference($firstOpen, initialValue: firstOpen, to: firstOpenPreference)
    }
    
    // Regular binding for simple types
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

    // Special binding for enum types
    private func bindEnumPreference<EnumType: RawRepresentable, Preference: PreferenceStorable>(
        _ publisher: Published<EnumType>.Publisher, initialValue: EnumType, to preference: Preference)
        where Preference.ValueType == EnumType.RawValue, EnumType.RawValue: Equatable {
        preference.set(initialValue.rawValue)
        publisher
            .sink { value in
                preference.set(value.rawValue)
            }
            .store(in: &cancellables)
    }

}


