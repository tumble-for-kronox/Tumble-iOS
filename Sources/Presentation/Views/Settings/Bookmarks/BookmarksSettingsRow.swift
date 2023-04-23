//
//  BookmarksSettingsRow.swift
//  Tumble
//
//  Created by Adis Veletanlic on 3/29/23.
//

import RealmSwift
import SwiftUI

struct BookmarkSettingsRow: View {
    @ObservedRealmObject var schedule: Schedule
    let index: Int
    let onDelete: (IndexSet, String) -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                onDelete(IndexSet(arrayLiteral: index), schedule.scheduleId)
            }, label: {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(.onSurface)
            })
            .padding(.trailing, 5)
            HStack {
                Toggle(isOn: $schedule.toggled) {
                    Text(schedule.scheduleId)
                        .font(.system(size: 16))
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.surface)
            .cornerRadius(10)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
    }
}
