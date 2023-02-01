//
//  OnboardingView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI
import PermissionsSwiftUICamera
import PermissionsSwiftUINotification

typealias UpdateUserOnBoarded = () -> Void

struct OnBoardingView: View {
    @ObservedObject var viewModel: OnBoardingViewModel
    @State private var viewedTab: Int = 0
    @State private var animateButton: Bool = true
    @State private var buttonOffset: CGFloat = 800
    let updateUserOnBoarded: UpdateUserOnBoarded
    
    let constResetButtonHeight: CGFloat = 800.0
    let constButtonOffset: CGFloat = 485.0
    
    init(viewModel: OnBoardingViewModel, updateUserOnBoarded: @escaping UpdateUserOnBoarded) {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.primary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.surface)
    
        self.viewModel = viewModel
        self.updateUserOnBoarded = updateUserOnBoarded
    }
    
    var body: some View {
        ZStack {
            VStack {
                TabView (selection: $viewedTab) {
                    OnBoardingViewBuilder (header: "Let's get started", subHeader: "We'll walk you through how to use Tumble") {
                        AppFeaturesListView()
                    }.tag(0)
                    OnBoardingViewBuilder (header: "Saving schedules", subHeader: "Here's how to save a schedule") {
                        SavingSchedulesView()
                    }.tag(1)
                    OnBoardingViewBuilder (header: "Signing up for exams", subHeader: "Here's how to sign up for an exam") {
                        SigningUpExamsView()
                    }.tag(2)
                    OnBoardingViewBuilder (header: "Booking rooms", subHeader: "Here's how to book a room") {
                        BookingRoomsView()
                    }.tag(3)
                    OnBoardingViewBuilder (header: "Setting notifications", subHeader: "Here's how to set notifications") {
                        SettingNotificationsView()
                    }.tag(4)
                    OnBoardingViewBuilder (header: "Customizing course colors", subHeader: "Here's how to modify course colors") {
                        CustomizeCourseColorsView()
                    }.tag(5)
                    OnBoardingViewBuilder (header: "All done", subHeader: "Now we'll leave you to it. First, choose your university.") {
                        SchoolSelectionView(onSelectSchool: onSelectSchool)
                    }.tag(6)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .onChange(of: viewedTab, perform: { newValue in
                    if newValue == 6 {
                        withAnimation (.spring()) {
                            self.buttonOffset += self.constButtonOffset
                        }
                    } else if newValue < 6 && self.buttonOffset == self.constResetButtonHeight {
                        withAnimation (.spring()) {
                            self.buttonOffset -= self.constButtonOffset
                        }
                    }

                })
                
            }
            SkipButtonView(onClickSkip: onClickSkip)
                .offset(y: buttonOffset)
                .onAppear {
                    withAnimation (.spring()) {
                        self.buttonOffset -= self.constButtonOffset
                    }
                }
        }
    }
    
    func onClickSkip() -> Void {
        withAnimation(.spring()) {
            self.viewedTab = 6
        }
    }
    
    func onSelectSchool(school: School) -> Void {
        self.viewModel.onSelectSchool(school: school) {
            self.updateUserOnBoarded()
        }
    }
}
