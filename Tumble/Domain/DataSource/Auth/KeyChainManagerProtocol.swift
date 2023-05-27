//
//  KeyChainManagerProtocol.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-25.
//

import Foundation

protocol KeyChainManagerProtocol {
    func updateKeyChain(
        _ data: Data,
        for service: String,
        account: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    
    func deleteKeyChain(
        for service: String,
        account: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    
    func readKeyChain(for service: String, account: String) -> Data?
    
    func saveKeyChain(
        _ data: Data,
        for service: String,
        account: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
}
