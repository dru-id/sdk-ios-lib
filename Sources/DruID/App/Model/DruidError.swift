//
//  DruidError.swift
//  
//
//  Created on 18/1/23.
//

public enum DruidError: Error {
    case error(String)
    case settingsNotSet
    case userNotLogged
    case errorFetchingEditUserUrl
}
