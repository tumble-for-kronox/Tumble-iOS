//
//  SchoolModelData.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

var schools: [School] = load("schools.json")
let ladokUrl: String = "https://www.student.ladok.se/student/app/studentwebb/"

func load<T: Decodable>(_ filename: String) -> T {

    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
