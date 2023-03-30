//
//  AccessTokenData.swift
//  
//
//  Created on 11/1/23.
//

import Foundation

public struct SessionInfoData: Codable {
    public let accessToken: String?
    public let tokenType: String?
    public let expiresIn: Int?
    public let expiresAt: Date?
    public let refreshToken: String?
    public let loginStatus: LoginStatusData?
    public let scope: String?
    public let links: LinksData?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
        case refreshToken = "refresh_token"
        case loginStatus = "login_status"
        case scope
        case links
    }
}

extension SessionInfoData {
    
    func isValid() -> Bool {
        guard let accessToken = accessToken, let expiresAt = expiresAt else { return false }
        return !accessToken.isEmpty && expiresAt > Date()
    }
    
    public class LinksData: Codable {
        public let editAccount: String?
        
        enum CodingKeys: String, CodingKey {
            case editAccount = "edit_account"
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: SessionInfoData.LinksData.CodingKeys.self)
            try container.encodeIfPresent(self.editAccount, forKey: SessionInfoData.LinksData.CodingKeys.editAccount)
        }
    }
}
