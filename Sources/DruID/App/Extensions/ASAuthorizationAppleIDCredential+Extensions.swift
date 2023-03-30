//
//  ASAuthorizationAppleIDCredential+Extensions.swift
//  
//
//  Created on 2/2/23.
//

import Foundation
import AuthenticationServices

extension ASAuthorizationAppleIDCredential {
    
    enum JwtTokenDecodeErrors: Error {
        case badToken
        case other
    }
    
    func decode() throws -> [String: Any] {
        if let identityToken = identityToken {
            let jwtToken = String(data: identityToken, encoding: .utf8)
            if let jwtToken = jwtToken {
                let segments = jwtToken.components(separatedBy: ".")
                return try decodeJWTPart(segments[1])
            }
        }
        return [:]
    }
    
    private func base64Decode(_ base64: String) throws -> Data {
        let base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let decoded = Data(base64Encoded: padded) else {
            throw JwtTokenDecodeErrors.badToken
        }
        return decoded
    }
    
    private func decodeJWTPart(_ value: String) throws -> [String: Any] {
        let bodyData = try base64Decode(value)
        let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
        guard let payload = json as? [String: Any] else {
            throw JwtTokenDecodeErrors.other
        }
        return payload
    }
    
}
