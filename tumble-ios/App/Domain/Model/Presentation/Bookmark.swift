//
//  Bookmark.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import Foundation

class Bookmark: Identifiable, ObservableObject, Codable {
    
    @Published var toggled: Bool
    let id: String
    
    init(toggled: Bool, id: String) {
        self.toggled = toggled
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            toggled = try container.decode(Bool.self, forKey: .toggled)
            id = try container.decode(String.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(toggled, forKey: .toggled)
        try container.encode(id, forKey: .id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case toggled
        case id
    }
}
