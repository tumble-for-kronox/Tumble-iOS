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

struct OnBoarding: View {
    @ObservedObject var viewModel: OnBoardingViewModel
    @State private var viewedTab: Int = 0
    @State private var animateButton: Bool = true
    @State private var buttonOffset: CGFloat = 900.0
    let updateUserOnBoarded: UpdateUserOnBoarded
    
    let constResetButtonHeight: CGFloat = 900.0
    let constButtonOffset: CGFloat = 585.0
    
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
                        AppFeaturesList()
                    }.tag(0)
                    OnBoardingViewBuilder (header: "Saving schedules", subHeader: "Here's how to save a schedule") {
                        BookmarkInstructions()
                    }.tag(1)
                    OnBoardingViewBuilder (header: "Signing up for exams", subHeader: "Here's how to sign up for an exam") {
                        ExamInstructions()
                    }.tag(2)
                    OnBoardingViewBuilder (header: "Booking rooms", subHeader: "Here's how to book a room") {
                        BookingInstructions()
                    }.tag(3)
                    OnBoardingViewBuilder (header: "Setting notifications", subHeader: "Here's how to set notifications") {
                        NotificationInstructions()
                    }.tag(4)
                    OnBoardingViewBuilder (header: "Customizing course colors", subHeader: "Here's how to modify course colors") {
                        ColorInstructions()
                    }.tag(5)
                    OnBoardingViewBuilder (header: "All done", subHeader: "Now we'll leave you to it. First, choose your university.") {
                        SchoolSelection(onSelectSchool: onSelectSchool)
                    }.tag(6)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .onChange(of: viewedTab, perform: handleAnimation)
            }
            SkipButton(onClickSkip: onClickSkip)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(30)
                .offset(y: buttonOffset)
                .onAppear {
                    withAnimation(.spring()) {
                        buttonOffset -= constResetButtonHeight
                    }
                }
        }
        .zIndex(0)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    func handleAnimation(newValue: Int) {
        if newValue == 6 {
            withAnimation (.spring()) {
                self.buttonOffset += self.constResetButtonHeight
            }
        } else if newValue < 6 && self.buttonOffset == self.constResetButtonHeight {
            withAnimation (.spring()) {
                self.buttonOffset -= self.constResetButtonHeight
            }
        }
    }
    
    func onClickSkip() -> Void {
        withAnimation(.spring()) {
            self.viewedTab = 6
        }
    }
    
    func onSelectSchool(school: School) -> Void {
        viewModel.onSelectSchool(school: school, updateUserOnBoarded: updateUserOnBoarded)
    }
}
