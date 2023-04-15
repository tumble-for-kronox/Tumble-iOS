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
        description: NSLocalizedString("Search for schedules from the search page and download them locally. View them as a list or a in a dedicated calendar.", comment: "")),
    BoardingScreen(
        image: "GuyWithPhone",
        title: NSLocalizedString("Set notifications", comment: ""),
        description: NSLocalizedString("Get notified before important events and dates. Just press an event and set notifications for either a course or a single event.", comment: "")),
    BoardingScreen(
        image: "GirlProud",
        title: NSLocalizedString("Be creative", comment: ""),
        description: NSLocalizedString("Set custom colors for the courses in your schedules. Just press an event and modify the color to your liking.", comment: "")),
    BoardingScreen(
        image: "GuyWalking",
        title: NSLocalizedString("Booking", comment: ""),
        description: NSLocalizedString("Log in to your KronoX account and book resources and exams. Booking is easy, and notifications remind you to confirm the bookings you've created.", comment: "")),
]


struct OnBoarding: View {
    
    @ObservedObject var viewModel: OnBoardingViewModel
    @State private var viewedTab: Int = 0
    @State private var animateButton: Bool = true
    @State private var buttonOffset: CGFloat = 900.0
    @State var offset: CGFloat = .zero
        
    init(viewModel: OnBoardingViewModel) {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.primary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.surface)
    
        self.viewModel = viewModel
    }
    
    var body: some View {
        OffsetPageTabView(offset: $offset) {
            HStack {
                ForEach(boardingScreens) { screen in
                    VStack(spacing: 15) {
                        Image(screen.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: getRect().width - 120, height: getRect().width - 120)
                            .offset(y: -120)
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
                HStack(spacing: 8) {
                    ForEach(boardingScreens.indices, id: \.self) { index in
                        Circle()
                            .fill(Color.background)
                            .opacity(index == getIndex() ? 1 : 0.4)
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == getIndex() ? 1.3 : 0.85)
                            .animation(.easeInOut, value: getIndex())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 5)
            }
            .padding()
            .padding(.bottom, 20)
            ,alignment: .bottom
        )
        .sheet(isPresented: $viewModel.showSchoolSelection, content: {
            VStack {
                DraggingPill()
                SheetTitle(title: NSLocalizedString("Universities", comment: ""))
                SchoolSelection(onSelectSchool: onSelectSchool, schools: viewModel.schools)
            }
            .background(Color.background)
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
        viewModel.onSelectSchool(school: school)
    }
}
