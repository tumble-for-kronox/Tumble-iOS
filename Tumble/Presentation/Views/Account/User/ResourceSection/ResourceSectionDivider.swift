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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.onBackground)
                Spacer()
                if let destination = destination {
                    NavigationLink(destination: destination, label: {
                        HStack {
                            switch resourceType! {
                            case .event:
                                ResourceNavigationItem(title: "See all", image: "eyeglasses")
                            case .resource:
                                ResourceNavigationItem(title: "Book more", image: "plus")
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


private struct ResourceNavigationItem: View {
    
    let title: String
    let image: String?
    
    init(title: String, image: String? = nil) {
        self.title = title
        self.image = image
    }
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.onPrimary)
            if let image = image {
                Image(systemName: image)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.onPrimary)
            }
        }
        .padding(10)
        .background(Color.primary)
        .cornerRadius(15)
    }
    
}
