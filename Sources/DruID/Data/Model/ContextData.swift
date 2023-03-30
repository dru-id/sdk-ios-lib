//
//  File.swift
//  
//
//  Created on 9/2/23.
//

import Foundation

struct ContextData: Encodable {
    let objectType: String = "oauth_session"
    let accessToken: AccessTokenData
    let profile: ProfileData?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case profile
    }
}

extension ContextData {
    
    struct AccessTokenData: Encodable {
        let value: String
        let expiresAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case value
            case expiresAt = "expires_at"
        }
    }
    
    struct ProfileData: Encodable {
        let email: String?
        let name: String?
        let birthday: Date?
    }
    
}
