//
//  Bookmark.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import Foundation

class Bookmark: Identifiable, ObservableObject {
    
    init(toggled: Bool, id: String) {
        self.toggled = toggled
        self.id = id
    }
    
    @Published var toggled: Bool
    let id: String
}
