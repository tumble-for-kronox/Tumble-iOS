//
//  ResourceSelection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct ResourceSelection: View {
    
    @ObservedObject var parentViewModel: AccountViewModel
    @State private var selectedTimeIndex: Int = 0
    @State private var availabilityValues: [Response.AvailabilityValue] = [Response.AvailabilityValue]()
    let resource: Response.KronoxResourceElement
    
    var body: some View {
        if let timeslots = resource.timeSlots {
            VStack {
                Menu {
                    ForEach(Array(timeslots.enumerated()), id: \.offset) { index, timeslot in
                        if let timeslotId = timeslot.id,
                           resource.availabilities.timeslotHasAvailable(for: timeslotId),
                           let start = timeslot.from?.convertToHoursAndMinutes(),
                           let end = timeslot.to?.convertToHoursAndMinutes() {
                            Button(action: {
                                selectedTimeIndex = index
                            }, label: {
                                Text("\(start) - \(end)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.onSurface)
                            })
                        }
                    }
                } label: {
                    Button(action: {}, label: {
                        if let timeslot = timeslots[selectedTimeIndex],
                           let start = timeslot.from?.convertToHoursAndMinutes(),
                           let end = timeslot.to?.convertToHoursAndMinutes() {
                            HStack {
                                Text("\(start) - \(end)")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.onSurface)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.onSurface)
                            }
                            .padding(.horizontal, 15)
                        }
                    })
                    .buttonStyle(ResourceTimeButtonStyle())
                }
                ResourceRoomSelection(availabilityValues: $availabilityValues)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .onAppear {
                availabilityValues = resource.availabilities.getAvailabilityValues(for: selectedTimeIndex)
            }
            .onChange(of: selectedTimeIndex, perform: { _ in
                availabilityValues = resource.availabilities.getAvailabilityValues(for: selectedTimeIndex)
            })
        } else {
            Text("No timeslots")
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
        }
    }
}
