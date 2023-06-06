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
            ForEach(ViewType.allCases, id: \.self) { type in
                Button(action: {
                    parentViewModel.onChangeViewType(viewType: type)
                }, label: {
                    HStack {
                        type.icon
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isSelectedViewType(viewType: type) ? .onPrimary : .onSurface)
                        Text(NSLocalizedString(type.name, comment: ""))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isSelectedViewType(viewType: type) ? .onPrimary : .onSurface)
                    }
                })
                .buttonStyle(PillStyle(color: isSelectedViewType(viewType: type) ? Color.primary : Color.surface))
            }
            Spacer()
        }
        .padding(.horizontal, 15)
    }
    
    func isSelectedViewType(viewType: ViewType) -> Bool {
        return parentViewModel.defaultViewType == viewType
    }
}
