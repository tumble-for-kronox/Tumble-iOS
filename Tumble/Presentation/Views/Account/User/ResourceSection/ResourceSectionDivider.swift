//
//  UserOptions.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

enum ResourceType {
    case event
    case resource
}

struct ResourceSectionDivider<Content: View>: View {
    let content: Content
    let title: String
    let resourceType: ResourceType?
    let onBook: (() -> Void)?
    let destination: AnyView?
    
    init(
        title: String,
        resourceType: ResourceType? = nil,
        destination: AnyView? = nil,
        onBook: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.resourceType = resourceType
        self.onBook = onBook
        self.destination = destination
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.onBackground)
                Spacer()
                if let destination = destination {
                    NavigationLink(destination: destination, label: {
                        HStack {
                            switch resourceType! {
                            case .event:
                                Text(NSLocalizedString("See all", comment: ""))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            case .resource:
                                Text(NSLocalizedString("Book more", comment: ""))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                    })
                }
            }
            .padding(.bottom, 10)
            content
        }
        .padding(.vertical, 7.5)
        .padding(.horizontal, 17)
    }
}
