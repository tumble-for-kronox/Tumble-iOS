//
//  ToastFactory.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-05-31.
//

import Foundation

class ToastFactory {
    
    static let shared = ToastFactory()
    
    func setNotificationsAllEventsSuccess() -> Toast {
        Toast (
            type: .success,
            title: NSLocalizedString("Scheduled notifications", comment: ""),
            message: NSLocalizedString("Scheduled notifications for all available events", comment: "")
        )
    }
    
    func logOutSuccess() -> Toast {
        Toast(
            type: .success,
            title: NSLocalizedString("Logged out", comment: ""),
            message: NSLocalizedString("You have successfully logged out of your account", comment: "")
        )
    }
    
    func logInSuccess(as username: String) -> Toast {
        Toast(
            type: .success,
            title: NSLocalizedString("Logged in", comment: ""),
            message: String(format: NSLocalizedString("Successfully logged in as %@", comment: ""), username)
        )
    }
    
    func unBookedResourceSuccess() -> Toast {
        Toast(
            type: .success,
            title: NSLocalizedString("Unbooked resource", comment: ""),
            message: NSLocalizedString("You have unbooked the selected resource", comment: "")
        )
    }
    
    func bookedResourceSuccess() -> Toast {
        Toast(
            type: .success,
            title: NSLocalizedString("Booked", comment: ""),
            message: NSLocalizedString("Successfully booked resource", comment: "")
        )
    }
    
    func clearNotificationsAllEventsSuccess() -> Toast {
        Toast(
            type: .success,
            title: NSLocalizedString("Cancelled notifications", comment: ""),
            message: NSLocalizedString("Cancelled all available notifications set for events", comment: "")
        )
    }
    
    func unBookedResourceFailed() -> Toast {
        Toast(
            type: .error,
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("We couldn't unbook the specified resource", comment: "")
        )
    }
    
    func logOutFailed() -> Toast {
        Toast(
            type: .error,
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("Could not log out of your account", comment: "")
        )
    }
    
    func logInFailed() -> Toast {
        Toast(
            type: .error,
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("Something went wrong when logging in to your account", comment: "")
        )
    }
    
    func bookResourceFailed() -> Toast {
        Toast(
            type: .error,
            title: NSLocalizedString("Not booked", comment: ""),
            message: NSLocalizedString("Failed to book the specified resource", comment: "")
        )
    }
    
    func updateBookmarksFailed() -> Toast {
        Toast(
            type: .info,
            title: NSLocalizedString("Information", comment: ""),
            message: NSLocalizedString("Some schedules could not be updated. Either due to missing authorization or network errors.", comment: "")
        )
    }
    
    func noAvailableBookmarks() -> Toast {
        Toast(
            type: .info,
            title: NSLocalizedString("No available bookmarks", comment: ""),
            message: NSLocalizedString("It looks like there's no available bookmarks", comment: "")
        )
    }
    
    func setNotificationsAllEventsFailed() -> Toast {
        Toast(
            type: .error,
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("Failed to set notifications for all available events", comment: "")
        )
    }
    
    func autoSignupEnabled() -> Toast {
        Toast(
            type: .info,
            title: NSLocalizedString("Automatic signup", comment: ""),
            message: NSLocalizedString(
                "Automatic exam/event signup has been enabled, but make sure you are always registered for exams through your institution.",
                comment: "")
        )
    }
    
    func autoSignupDisabled() -> Toast {
        Toast(
            type: .info,
            title: NSLocalizedString("Automatic signup", comment: ""),
            message: NSLocalizedString("Automatic exam/event signup has been disabled.", comment: "")
        )
    }
    
}
