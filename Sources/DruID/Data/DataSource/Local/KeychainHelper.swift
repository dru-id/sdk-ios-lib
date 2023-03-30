//
//  KeychainHelper.swift
//
//
//  Created on 12/1/23.
//

import Foundation

final class KeychainHelper {
    
    static let shared = KeychainHelper()
        
    private func save(_ data: Data, service: String, account: String) {
        
        let query = [
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            // Item already exist, thus update it.
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            
            // Update existing item
            SecItemUpdate(query, attributesToUpdate)
        }
    }
    
    private func read(service: String, account: String) -> Data? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    private func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
}

extension KeychainHelper {
    
    private func save<T>(_ item: T, service: String, account: String) throws where T : Codable {
        // Encode as JSON data and save in keychain
        let data = try JSONEncoder().encode(item)
        save(data, service: service, account: account)
    }
    
    private func read<T>(service: String, account: String, type: T.Type) throws -> T? where T : Codable {
        
        // Read item data from keychain
        guard let data = read(service: service, account: account) else {
            return nil
        }
        
        // Decode JSON data to object
        let item = try JSONDecoder().decode(type, from: data)
        return item
    }
    
}

extension KeychainHelper {
    
    func read<T: Codable>(key: Key, account: String, decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data: T = try? read(service: key.rawValue, account: account, type: T.self) else { return nil }
        return data
    }
    
    func save<T: Codable>(_ value: T?, key: Key, account: String, encoder: JSONEncoder = JSONEncoder()) {
        guard let value = value else { delete(service: key.rawValue, account: account); return }
        try? save(value, service: key.rawValue, account: account)
    }
    
    func reset(account: String) {
        Key.allCases.forEach { delete(service: $0.rawValue, account: account); return }
    }
}

extension KeychainHelper {
    enum Key: String, CaseIterable {
        case settings
        case clientTokenData
        case loginResponse
        case entrypointSettings
    }
}


