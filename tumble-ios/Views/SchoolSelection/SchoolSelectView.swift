//
//  ContentView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//


import SwiftUI

struct SchoolSelectView: View {
    var body: some View {
        HStack {
            SchoolRow(school: schools[0])
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SchoolSelectView()
    }
}
