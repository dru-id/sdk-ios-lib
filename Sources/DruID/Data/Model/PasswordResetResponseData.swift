//
//  PasswordResetResponseData.swift
//  
//
//  Created on 17/2/23.
//

import Foundation

public struct PasswordResetResponseData: Codable {
    public let content: ContentData?
    public let result: ResultData
}

extension PasswordResetResponseData {
    
    public struct ContentData: Codable {
        public let objectType: String
        public let displayName: String?
        public let value: String?
        public let url: String?
    }
}

extension PasswordResetResponseData: CustomStringConvertible {
    
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
