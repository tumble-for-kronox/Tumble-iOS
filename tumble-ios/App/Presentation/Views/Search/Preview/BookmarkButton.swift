//
//  BookmarkButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import SwiftUI

struct BookmarkButton: View {
    
    let bookmark: () -> Void
    
    @Binding var disableButton: Bool
    @Binding var previewButtonState: ButtonState
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            bookmark()
        }) {
            HStack {
                switch previewButtonState {
                case .loading:
                    CustomProgressIndicator(tint: .onPrimary)
                case .saved:
                    HStack (spacing: 10) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.onPrimary)
                        Text("Remove")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                case .notSaved:
                    HStack (spacing: 10) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 20))
                            .foregroundColor(.onPrimary)
                        Text("Bookmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                }
            }
        }
        .frame(minWidth: 80)
        .padding()
        .id(previewButtonState)
        .background(Color.primary)
        .cornerRadius(10)
        .padding(15)
        .padding(.leading, 5)
        .disabled(disableButton)
    }
}
