//
//  LoginResponseData.swift
//
//
//  Created on 11/1/23.
//

import Foundation

public struct LoginResponseData: Codable {
    public let content: ContentData?
    public let result: ResultData
}

extension LoginResponseData {
    
    public struct ContentData: Codable {
        public let user: UserData?
        public let sessionInfo: SessionInfoData?
        
        enum CodingKeys: String, CodingKey {
            case user
            case sessionInfo = "session_info"
        }
    }
}

extension LoginResponseData: CustomStringConvertible {
    
    public var description: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        if let jsonData = try? jsonEncoder.encode(self) {
            if let json = String(data: jsonData, encoding: String.Encoding.utf8) {
                return json
            }
        }
        return ""
    }
}

