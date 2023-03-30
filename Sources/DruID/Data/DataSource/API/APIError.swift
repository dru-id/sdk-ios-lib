//
//  APIError.swift
//  
//
//  Created on 9/1/23.
//

import Foundation

enum APIError: Error {
    case http(code: Int, data: Data)
    case `internal`
    case decoding(Error)
    case encoding(Error)
    case invalidClientToken
    case invalidUserToken
    case sdkSettingsNotSet
}
