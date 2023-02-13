//
//  KeyChainManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import Foundation

protocol KeyChainManagerProtocol {
    
    func delete(service: String, account: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    func read(service: String, account: String) -> String?
    
    func save(_ data: Data, service: String, account: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    func update(_ data: Data, service: String, account: String, completion: @escaping (Result<Bool, Error>) -> Void)
}
