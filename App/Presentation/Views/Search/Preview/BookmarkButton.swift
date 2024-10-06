//
//  BookmarkButton.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import SwiftUI

struct BookmarkButton: View {
    let bookmark: () -> Void
    
    @Binding var buttonState: ButtonState
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            withAnimation {
                bookmark()
            }
        }) {
            HStack {
                switch buttonState {
                case .loading, .disabled:
                    CustomProgressIndicator(color: .onPrimary)
                case .saved:
                    HStack(spacing: Spacing.small) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.onPrimary)
                        Text(NSLocalizedString("Remove", comment: ""))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                case .notSaved:
                    HStack(spacing: Spacing.small) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 16))
                            .foregroundColor(.onPrimary)
                        Text(NSLocalizedString("Save", comment: ""))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                }
            }
        }
        .buttonStyle(PillStyle(color: .primary))
        .padding(Spacing.medium)
    }
}
