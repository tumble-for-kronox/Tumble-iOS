/**
 The test class for `RootViewModel`.
 */

import XCTest
@testable import tumble_ios

class RootViewModelTests: XCTestCase {
    
    /// The system under test.
    var sut: RootViewModel!
    
    @MainActor
    override func setUp() {
        sut = RootViewModel(userNotOnBoarded: true)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    /**
     Tests that the `currentView` property is set to `.onboarding` when the user is not onboarded.
     */
    @MainActor
    func testInit_WhenUserNotOnBoarded_ShouldSetCurrentViewToOnboarding() {
        XCTAssertEqual(sut.currentView, .onboarding)
    }
    
    /**
     Tests that the `parentViewModel` property is nil when the user is not onboarded.
     */
    @MainActor
    func testInit_WhenUserNotOnBoarded_ShouldNotSetParentViewModel() {
        XCTAssertNil(sut.parentViewModel)
    }
    
    /**
     Tests that the `onBoardingViewModel` property is not nil when the user is not onboarded.
     */
    @MainActor
    func testInit_WhenUserNotOnBoarded_ShouldSetOnBoardingViewModel() {
        XCTAssertNotNil(sut.onBoardingViewModel)
    }
    
    /**
     Tests that the `currentView` property is set to `.app` when the user is onboarded.
     */
    @MainActor
    func testInit_WhenUserIsOnBoarded_ShouldSetCurrentViewToApp() {
        let sut = RootViewModel(userNotOnBoarded: false)
        XCTAssertEqual(sut.currentView, .app)
    }
    
    /**
     Tests that the `onBoardingViewModel` property is nil when the user is onboarded.
     */
    @MainActor
    func testInit_WhenUserIsOnBoarded_ShouldNotSetOnBoardingViewModel() {
        let sut = RootViewModel(userNotOnBoarded: false)
        XCTAssertNil(sut.onBoardingViewModel)
    }
    
    /**
     Tests that the `parentViewModel` property is not nil when the user is onboarded.
     */
    @MainActor
    func testInit_WhenUserIsOnBoarded_ShouldNotSetParentViewModel() {
        let sut = RootViewModel(userNotOnBoarded: false)
        XCTAssertNotNil(sut.parentViewModel)
    }
    
}
