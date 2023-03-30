//
//  RefreshClientTokenRequestData.swift
//  
//
//  Created on 11/1/23.
//

import Foundation

struct RefreshAccessTokenRequestData: Encodable {
    let clientId: String
    let clientSecret: String
    let grantType: String = "refresh_token"
    let refreshToken: String
}

extension RefreshAccessTokenRequestData {
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case grantType = "grant_type"
        case refreshToken = "refresh_token"
    }    
}

extension RefreshAccessTokenRequestData: UrlEncodedRequest {
    
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "grant_type", value: grantType),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        return components
    }
}
