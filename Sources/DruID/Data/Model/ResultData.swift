//
//  ResultData.swift
//
//
//  Created on 20/1/23.
//

import Foundation

public struct ResultData: Codable {
    public let status: Int
    public let elapsed: Double?
    public let node: String?
    public let errors: [ErrorMessageData]?
}

extension ResultData {
    public struct ErrorMessageData: Codable {
        public let message: String
        public let details: String?
    }
}

