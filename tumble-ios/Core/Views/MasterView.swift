//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

import SwiftUI


struct RootView: View {
    @StateObject private var viewModel = ViewModel()
    @State var toast: Toast? = Toast(type: .success, title: "Launched Tumble!", message: "Successfully launched Tumble!")
    
    var body: some View {
        Group {
            NavigationView {
                CustomTabBar()
                }.sheet(isPresented: $viewModel.missingSchool, content: {
                    SchoolSelectView(selectSchoolCallback: { schoolName in
                        viewModel.selectSchool(school: schoolName)
                }).interactiveDismissDisabled(true)
            })
        }
    }
}

struct MasterView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
