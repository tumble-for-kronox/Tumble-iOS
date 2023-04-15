//
//  Permissions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 4/15/23.
//

import Foundation

/// Checks if a given file URL exists in the path
/// and if the file can be read
func checkFile(at url: URL) -> Result<Void, Error> {
    let fileManager = FileManager.default
    
    // Check if the file exists at the specified file path
    guard fileManager.fileExists(atPath: url.path) else {
        return .failure(.internal(reason: "File does not exist"))
    }
    
    // Check if the file can be read
    guard fileManager.isReadableFile(atPath: url.path) else {
        return .failure(.internal(reason: "File cannot be read"))
    }
    
    return .success(())
}
