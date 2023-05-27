//
//  ViewSwitcher.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-12.
//

import SwiftUI

struct ViewSwitcher: View {
    @ObservedObject var parentViewModel: BookmarksViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                parentViewModel.onChangeViewType(viewType: .list)
            }, label: {
                HStack {
                    Image(systemName: "list.dash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelectedViewType(viewType: .list) ? .onPrimary : .onSurface)
                    Text(NSLocalizedString("List", comment: ""))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelectedViewType(viewType: .list) ? .onPrimary : .onSurface)
                }
            })
            .buttonStyle(PillStyle(color: isSelectedViewType(viewType: .list) ? Color.primary : Color.surface))
            Button(action: {
                parentViewModel.onChangeViewType(viewType: .calendar)
            }, label: {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelectedViewType(viewType: .calendar) ? .onPrimary : .onSurface)
                    Text(NSLocalizedString("Calendar", comment: ""))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelectedViewType(viewType: .calendar) ? .onPrimary : .onSurface)
                }
            })
            .buttonStyle(PillStyle(color: isSelectedViewType(viewType: .calendar) ? Color.primary : Color.surface))
            Spacer()
        }
        .padding(.horizontal, 15)
    }
    
    func isSelectedViewType(viewType: BookmarksViewType) -> Bool {
        return parentViewModel.defaultViewType == viewType
    }
}
