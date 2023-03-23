//
//  ResourceTimeDropdown.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct ResourceTimeDropdownMenu: View {
    
    let resource: Response.KronoxResourceElement
    let timeslots: [Response.TimeSlot]
    
    @State var isSelecting: Bool = false
    @State var selectionTitle: String = ""
    @Binding var selectedIndex: Int

    var body: some View {
        VStack {
            HStack {
                Text(selectionTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.onSurface)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.onSurface)
            }
            .padding(.horizontal, 15)
            if isSelecting {
                Divider()
                    .background(.white)
                    .padding(.horizontal)

                VStack(spacing: 5) {
                    ForEach(Array(timeslots.enumerated()), id: \.offset) { index, timeslot in
                        if let timeslotId = timeslot.id,
                           resource.availabilities.timeslotHasAvailable(for: timeslotId),
                           let start = timeslot.from?.convertToHoursAndMinutes(),
                           let end = timeslot.to?.convertToHoursAndMinutes() {
                            DropdownMenuItemView(
                                isSelecting: $isSelecting,
                                selectiontitle: $selectionTitle,
                                selectedIndex: $selectedIndex,
                                item: DropdownItem(id: timeslotId,
                                title: "\(start) - \(end)",
                                onSelect: {
                                    selectedIndex = index
                                })
                            )
                        }
                    }
                }

            }
        }
        .onAppear {
            if let start = timeslots[selectedIndex].from?.convertToHoursAndMinutes(),
               let end = timeslots[selectedIndex].to?.convertToHoursAndMinutes() {
                selectionTitle = "\(start) - \(end)"
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(Color.surface)
        .cornerRadius(20)
        .padding(.horizontal, 15)
        .padding(.bottom, 15)
        .onTapGesture {
            withAnimation(.easeInOut) {
                isSelecting.toggle()
            }
        }
    }

}


fileprivate struct DropdownItem: Identifiable {
    let id: Int
    let title: String
    let onSelect: () -> Void
}


fileprivate struct DropdownMenuItemView: View {
    @Binding var isSelecting: Bool
    @Binding var selectiontitle: String
    @Binding var selectedIndex: Int

    let item: DropdownItem

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                isSelecting = false
                selectiontitle = item.title
            }
            item.onSelect()
        }) {
            HStack {
                Text(item.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.onSurface)
                Spacer()
                if selectedIndex == item.id {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.onSurface)
                }
            }
            .padding()
            .foregroundColor(.onBackground)
        }
    }
}
