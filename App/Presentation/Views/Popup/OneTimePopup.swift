//
//  OneTimePopup.swift
//  App
//
//  Created by Adis Veletanlic on 4/27/24
//

import Foundation
import SwiftUI
import MijickPopupView

struct OneTimePopup: CentrePopup {
    func createContent() -> some View {
            VStack(spacing: 0) {
                createIllustration()
                Spacer().frame(height: max(12, 0))
                createTitle()
                Spacer().frame(height: max(12, 0))
                createDescription()
                Spacer().frame(height: max(32, 0))
                createInterestButton()
                Spacer().frame(height: max(8, 0))
                createDismissButton()
            }
            .padding([.top, .bottom, .horizontal], 24)
            .background(Color.surface)
            .cornerRadius(15)
        }
}


private extension OneTimePopup {
    
    func createIllustration() -> some View {
        Image("AppIconOpaque")
            .resizable()
            .frame(width: 80, height: 80)
    }
    
    
    func createTitle() -> some View {
        Text(NSLocalizedString("Are you a developer?", comment: ""))
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.onSurface)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    
    func createDescription() -> some View {
        Text(NSLocalizedString("Tumble is always on the lookout for developers. If you're interested in contributing, please let us know!", comment: ""))
            .font(.system(size: 14))
            .foregroundColor(.onSurface)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    
    func createInterestButton() -> some View {
        Button(action: {
            NotificationCenter.default.post(name: .unBlurOneTimePopup, object: nil)
            dismiss()
            if let url = URL(string: "mailto:tumbleapps.studios@gmail.com") {
                UIApplication.shared.open(url)
            }
        }) {
            Text(NSLocalizedString("Sign me up", comment: ""))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.onPrimary)
        }
        .buttonStyle(WideAnimatedButtonStyle())
    }
    
    
    func createDismissButton() -> some View {
        Button(action: {
            NotificationCenter.default.post(name: .unBlurOneTimePopup, object: nil)
            dismiss()
        } ) {
            Text(NSLocalizedString("Back", comment: ""))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .buttonStyle(WideAnimatedButtonStyle(color: .gray))
    }
}


extension OneTimePopup {
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
            popup
                .horizontalPadding(28)
                .tapOutsideToDismiss(true)
        }
}
