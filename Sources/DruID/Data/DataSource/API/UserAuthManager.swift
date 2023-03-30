//
//  UserAuthManager.swift
//  
//
//  Created on 20/1/23.
//

import Foundation

actor UserAuthManager {
    private var refreshTokenTask: Task<SessionInfoData, Error>?
    private var refresToken: () async throws -> SessionInfoData?
    
    private var currentToken: SessionInfoData? {
        return DruID.shared.dependencyManager?.keychainDataSource.loginResponse?.content?.sessionInfo
    }
    
    init(refresToken: @escaping () async throws -> SessionInfoData?) {
        self.refresToken = refresToken
    }
    
    func validToken() async throws -> SessionInfoData {
        if let refreshTokenTask = refreshTokenTask {
            return try await refreshTokenTask.value
        }
        
        guard let token = currentToken else {
            throw APIError.invalidUserToken
        }
        
        if token.isValid() {
            return token
        }
        
        return try await refreshToken()
    }
    
    func refreshToken() async throws -> SessionInfoData {
        if let refreshTokenTask = refreshTokenTask {
            return try await refreshTokenTask.value
        }
        
        let task = Task { () throws -> SessionInfoData in
            defer { refreshTokenTask = nil }
            
            // Call to obtain new client token (no refresh allowed)
            let token = try await refresToken()
            if let safeToken = token {
                return safeToken
            }
            
            throw APIError.invalidUserToken
        }
        
        self.refreshTokenTask = task
        
        return try await task.value
    }
}
