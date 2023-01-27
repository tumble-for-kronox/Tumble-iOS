//
//  SearchButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import SwiftUI

struct SearchButtonView: View {
    var body: some View {
        NavigationLink(destination:
            SearchParentView()
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton()), label: {
            Image(systemName: "magnifyingglass")
                    .font(.system(size: 17))
                .foregroundColor(Color("OnBackground"))
        })
    }
}

struct SearchButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SearchButtonView()
    }
}
