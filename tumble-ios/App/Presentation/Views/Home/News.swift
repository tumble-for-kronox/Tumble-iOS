//
//  News.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-04.
//

import SwiftUI

struct News: View {
    
    let news: Response.NewsItems?
    
    var body: some View {
        VStack {
            Button(action: {}, label: {
                HStack (alignment: .center) {
                    Text(
                        String(format: NSLocalizedString("News from us (%@)", comment: ""),
                               news != nil ? String(news!.count) : "0")
                    )
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.onBackground)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundColor(.onBackground)
                }
                .frame(maxWidth: .infinity)
            })
            .buttonStyle(WideAnimatedButtonStyle())
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
    }
}
