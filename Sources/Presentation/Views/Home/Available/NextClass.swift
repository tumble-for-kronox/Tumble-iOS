//
//  HomeNextClass.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-04.
//

import SwiftUI

struct NextClass: View {
    let nextClass: Event?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let nextClass = nextClass {
                    Text(nextClass.from.formatDate() ?? "")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(NSLocalizedString("Next class", comment: ""))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.onBackground)
            }
            if let nextClass = nextClass, let course = nextClass.course {
                let color: Color = course.color.toColor()
                CompactEventButtonLabel(event: nextClass, color: color)
                    .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100, alignment: .center)
                    .background(color.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.bottom, 10)
            } else {
                Text(NSLocalizedString("No upcoming class", comment: ""))
                    .font(.system(size: 16))
                    .foregroundColor(.onBackground)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(.top, 20)
    }
}
