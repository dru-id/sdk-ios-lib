//
//  ObtainClientTokenResponseData.swift
//  
//
//  Created on 9/1/23.
//

import Foundation

struct ClientTokenData: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let expiresAt: Date
}

extension ClientTokenData {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
    }
}

extension ClientTokenData {
    
    func isValid() -> Bool {
        return !accessToken.isEmpty && expiresAt > Date()
    }
    
}
