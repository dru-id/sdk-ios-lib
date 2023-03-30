//
//  ObtainClientTokenRequestData.swift
//  
//
//  Created on 9/1/23.
//

import Foundation

struct ObtainClientTokenRequestData: Encodable {
    let clientId: String
    let clientSecret: String
    let grantType: String = "client_credentials"
}

extension ObtainClientTokenRequestData {
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case grantType = "grant_type"
    }
}

extension ObtainClientTokenRequestData: UrlEncodedRequest {
    
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "grant_type", value: grantType)
        ]
        return components
    }
}
