//
//  NewsSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-05.
//

import SwiftUI

struct NewsSheet: View {
    
    let news: Response.NewsItems?
    
    var body: some View {
        VStack {
            DraggingPill()
            SheetTitle(title: "News")
            HStack {
                SearchButton(search: {})
                TextField(NSLocalizedString("Search news", comment: ""), text: .constant(""))
                    .searchBoxText()
            }
            .searchBox()
            HStack {
                Text(NSLocalizedString("Recent news", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.onBackground)
                Spacer()
            }
            .padding([.top, .horizontal], 15)
            VStack {
                
            }
            VStack {
                
            }
            Spacer()
        }
        .background(Color.background)
    }
}
