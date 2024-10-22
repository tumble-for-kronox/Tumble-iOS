//
//  RectangularEvent.swift
//  WidgetExtension
//
//  Created by Timur Ramazanov on 21.10.2024.
//

import SwiftUI
import RealmSwift
import WidgetKit

struct RectangularEvent: View {
    let event: Event
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(.system(size: 16, weight: .medium))
                .lineLimit(1)
            if let timeFrom = event.from.convertToHoursAndMinutesISOString(),
               let timeTo = event.to.convertToHoursAndMinutesISOString()
            {
                HStack {
                    HStack {
                        Text("\(timeFrom)")
                            .font(.system(size: 13))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11))
                        Text("\(timeTo)")
                            .font(.system(size: 13))
                    }
                }
            }
            HStack(spacing: 3) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 11))
                Text(event.locations.first?.locationId.capitalized ?? NSLocalizedString("Unknown", comment: ""))
                    .font(.system(size: 13))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
