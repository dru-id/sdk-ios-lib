//
//  ClientAuthManager.swift
//  
//
//  Created on 11/1/23.
//

import Foundation

actor ClientAuthManager {
    private var refreshTokenTask: Task<ClientTokenData, Error>?
    private var obtainNewClientToken: () async throws -> ClientTokenData?
    
    private var currentToken: ClientTokenData? {
        return DruID.shared.dependencyManager?.keychainDataSource.clientTokenData
    }
    
    init(obtainNewClientToken: @escaping () async throws -> ClientTokenData?) {
        self.obtainNewClientToken = obtainNewClientToken
    }
    
    func validToken() async throws -> ClientTokenData {
        if let refreshTokenTask = refreshTokenTask {
            return try await refreshTokenTask.value
        }
        
        guard let token = currentToken else {
            throw APIError.invalidClientToken
        }
        
        if token.isValid() {
            return token
        }
        
        return try await refreshToken()
    }
    
    func refreshToken() async throws -> ClientTokenData {
        if let refreshTokenTask = refreshTokenTask {
            return try await refreshTokenTask.value
        }
        
        let task = Task { () throws -> ClientTokenData in
            defer { refreshTokenTask = nil }
            
            // Call to obtain new client token (no refresh allowed)
            let token = try await obtainNewClientToken()
            if let safeToken = token {
                return safeToken
            }
            
            throw APIError.invalidClientToken
        }
        
        self.refreshTokenTask = task
        
        return try await task.value
    }
}
