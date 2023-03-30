//
//  LoginStatusData.swift
//
//
//  Created on 20/1/23.
//

import Foundation

public struct LoginStatusData: Codable {
    public let uid: Int
    public let oid: String
    public let connectState: String
    
    enum CodingKeys: String, CodingKey {
        case uid
        case oid
        case connectState = "connect_state"
    }
}

