//
//  SupportView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        ZStack {
            List {
                Section {
                    SupportOption(title: "Have a burning question?", image: "flame")
                }
                Section {
                    SupportOption(title: "Report a bug", image: "ant")
                }
                Section {
                    SupportOption(title: "See who contributed", image: "person.2")
                }
                Section {
                    SupportOption(title: "How to use the app", image: "info.circle")
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
