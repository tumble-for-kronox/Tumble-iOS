//
//  OnboardingView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

typealias UpdateUserOnBoarded = () -> Void

struct BoardingScreen: Identifiable {
    var id = UUID().uuidString
    var image: String
    var title: String
    var description: String
}

var boardingScreens: [BoardingScreen] = [
    BoardingScreen(
        image: "GuyPointing",
        title: NSLocalizedString("Save schedules", comment: ""),
        description: NSLocalizedString("Search for schedules from the search page and download them locally", comment: "")),
    BoardingScreen(
        image: "GuyWithPhone",
        title: NSLocalizedString("Set notifications", comment: ""),
        description: NSLocalizedString("Get notified before important events and dates", comment: "")),
    BoardingScreen(
        image: "GirlProud",
        title: NSLocalizedString("Be creative", comment: ""),
        description: NSLocalizedString("Set custom colors for the courses in your schedules", comment: "")),
    BoardingScreen(
        image: "GuyWalking",
        title: NSLocalizedString("Booking", comment: ""),
        description: NSLocalizedString("Log in to your Kronox account and book resources and exams", comment: "")),
]


struct OnBoarding: View {
    
    @ObservedObject var viewModel: OnBoardingViewModel
    @State private var viewedTab: Int = 0
    @State private var animateButton: Bool = true
    @State private var buttonOffset: CGFloat = 900.0
    let updateUserOnBoarded: UpdateUserOnBoarded
    @State var offset: CGFloat = .zero
    
    init(viewModel: OnBoardingViewModel, updateUserOnBoarded: @escaping UpdateUserOnBoarded) {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.primary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.surface)
    
        self.viewModel = viewModel
        self.updateUserOnBoarded = updateUserOnBoarded
    }
    
    var body: some View {
        OffsetPageTabView(offset: $offset) {
            HStack {
                ForEach(boardingScreens) { screen in
                    VStack(spacing: 15) {
                        Image(screen.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: getRect().width - 100, height: getRect().width - 100)
                            .offset(y: -150)
                        VStack(alignment: .leading, spacing: 15) {
                            Text(screen.title)
                                .font(.largeTitle.bold())
                                .foregroundColor(.onPrimary)
                            Text(screen.description)
                                .fontWeight(.semibold)
                                .foregroundColor(.onPrimary)
                                .padding(.trailing, 90)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .offset(y: -70)
                    }
                    .frame(width: getRect().width)
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.background)
                .frame(width: getRect().width - 100, height: getRect().width - 100)
                .scaleEffect(2)
                .rotationEffect(.init(degrees: 25))
                .rotationEffect(.init(degrees: getRotation()))
                .offset(y: -getRect().width + 20)
            ,alignment: .leading
        )
        .background(
            Color.primary
                .animation(.easeInOut, value: getIndex())
        )
        .ignoresSafeArea(.container, edges: .all)
        .overlay(
            VStack {
                HStack {
                    Button {
                        viewModel.showSchoolSelection = true
                    } label: {
                        Text(NSLocalizedString("Select university", comment: ""))
                            .fontWeight(.semibold)
                            .foregroundColor(.onBackground)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(Color.background)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                    }
                    .buttonStyle(AnimatedButtonStyle())
                    Spacer()
                }
            }
            .padding()
            .padding(.bottom, 20)
            ,alignment: .bottom
        )
        .sheet(isPresented: $viewModel.showSchoolSelection, content: {
            SchoolSelection(onSelectSchool: onSelectSchool, schools: viewModel.schools)
        })
        .onDisappear {
            viewModel.showSchoolSelection = false
        }
        .zIndex(0)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    func getRotation() -> Double {
        let process = offset / (getRect().width * 4)
        
        let rotation = Double(process) * 360
        
        return rotation
    }
    
    func getIndex() -> Int {
        
        let process = offset / getRect().width
        
        return Int(process)
        
    }
    
    func onSelectSchool(school: School) -> Void {
        viewModel.onSelectSchool(school: school, updateUserOnBoarded: updateUserOnBoarded)
    }
}
