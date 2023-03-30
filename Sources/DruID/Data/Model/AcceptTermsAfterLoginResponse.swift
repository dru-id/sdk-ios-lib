//
//  AcceptTermsAfterLoginResponse.swift
//  
//
//  Created on 22/2/23.
//

import Foundation

public struct AcceptTermsAfterLoginResponse: Codable {
    public let content: ContentData?
    public let result: ResultData
}

extension AcceptTermsAfterLoginResponse {
    
    public struct ContentData: Codable {
        let assertions: AssertionsData?
    }
    
    struct AssertionsData: Codable {
        let objectType: String
        let items: [AssertionItemData]
        let totalItems: Int
    }
    
    struct AssertionItemData: Codable {
        let objectType: String
        let displayName: String
        let extended: String?
        let type: String
        let typology: String
        let mandatory: Bool
    }
}

extension AcceptTermsAfterLoginResponse: CustomStringConvertible {
    
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
