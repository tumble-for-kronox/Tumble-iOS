//
//  KeyChainManager.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-25.
//

import Foundation

/// Handles operations on user KeyChain
/// such as storing, deleting, updating: basic CRUD operations
class KeyChainManager: KeyChainManagerProtocol {
    func updateKeyChain(
        _ data: Data,
        for service: String,
        account: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as [CFString: Any] as CFDictionary

        let attributes = [
            kSecValueData: data
        ] as CFDictionary

        let status = SecItemUpdate(query, attributes)
        guard status == errSecSuccess else {
            completion(.failure(.internal(reason: status.description)))
            return
        }
        completion(.success(true))
    }
    
    func deleteKeyChain(
        for service: String,
        account: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as [CFString: Any] as CFDictionary
            
        // Delete item from keychain
        SecItemDelete(query)
        AppLogger.shared.debug("Deleted item from keychain")
        completion(.success(true))
    }
    
    func readKeyChain(for service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as [CFString: Any] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let data = result as? Data else {
            return nil
        }
        return data
    }
    
    func saveKeyChain(
        _ data: Data,
        for service: String,
        account: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as [CFString: Any] as CFDictionary
            
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
            
        if status == errSecDuplicateItem {
            updateKeyChain(data, for: service, account: account, completion: completion)
            return
        }
            
        if status != errSecSuccess {
            AppLogger.shared.critical("Could not save item to keychain -> \(status)")
            completion(.failure(.internal(reason: status.description)))
            return
        }
            
        AppLogger.shared.debug("Added item to keychain")
        completion(.success(true))
    }
}
