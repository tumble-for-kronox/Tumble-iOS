//
//  UIApplicationExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-30.
//

import Foundation
import StoreKit
import UIKit

extension UIApplication {
    // Override variable
    private var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap { $0 as? UIWindowScene }?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    func requestReview() {
        if let keyWindow = UIApplication.shared.keyWindow, let windowScene = keyWindow.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    func shareFeedback() {
        if let url = URL(string: "mailto:tumblestudios.app@gmail.com") {
            UIApplication.shared.open(url)
        }
    }
}
