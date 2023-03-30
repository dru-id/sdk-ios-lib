//
//  RegisterResponseData.swift
//
//
//  Created on 11/1/23.
//

import Foundation

public struct RegisterResponseData: Codable {
    public let content: ContentData?
    public let result: ResultData
}

extension RegisterResponseData {
    
    public struct ContentData: Codable {
        public let id: String?
        public let objectType: String
        public let confirmed: Bool
        public let objectId: String
    }
}

extension RegisterResponseData: CustomStringConvertible {
    
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

