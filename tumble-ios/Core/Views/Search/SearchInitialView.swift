//
//  SearchInitialView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct SearchInitialView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("So, this is where you find your schedules.")
                .font(.headline)
                .padding(20)
                .background(Color("PrimaryColor").opacity(0.75))
                .clipShape(BubbleShape(myMessage: true))
                .foregroundColor(.white)
                .padding(.bottom, 30)
                .padding(.leading, 5)
            Text("You can try searching for your program name, what you study, or even your own name if you're a teacher!")
                .font(.headline)
                .padding(20)
                .background(Color("PrimaryColor").opacity(0.75))
                .clipShape(BubbleShape(myMessage: false))
                .foregroundColor(.white)
                .padding(.bottom, 30)
        }
        .padding(.bottom, 30)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }
}

struct SearchInitialView_Previews: PreviewProvider {
    static var previews: some View {
        SearchInitialView()
    }
}
