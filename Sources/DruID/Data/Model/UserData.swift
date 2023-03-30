//
//  UserData.swift
//
//
//  Created on 18/1/23.
//

import Foundation


public struct UserData: Codable {
    let objectType: String
    let appId: String
    let entrypointId: String
    let confirmed: Bool
    let ids: IdsData
    let datas: Datas?
    let assertions: AssertionsData?
    let typologies: [String]
    let updatedOn: Int
    let objectId: String
    
    enum CodingKeys: String, CodingKey {
        case objectType
        case appId = "app_id"
        case entrypointId = "entrypoint_id"
        case confirmed
        case ids
        case datas
        case assertions
        case typologies
        case updatedOn = "updated_on"
        case objectId
    }
}

extension UserData {
    
    struct IdsData: Codable {
        let pulseId: IdItemData?
        let email: IdItemData?
        let facebookId: IdItemData?
        let appleId: IdItemData?

        enum CodingKeys: String, CodingKey {
            case pulseId = "pulse_id"
            case email
            case facebookId = "facebook_id"
            case appleId = "apple_id"
        }
    }
    
    struct IdItemData: Codable {
        let objectType: String
        let displayName: String
        let app: String
        let value: String
        let confirmed: Bool
    }
    
    struct Datas: Codable {
        let birthday: DatasItemData
        let country: DatasItemData
        let preferredLocale: DatasItemData
        let surname: DatasItemData
        let name: DatasItemData
        
        enum CodingKeys: String, CodingKey {
            case birthday
            case country
            case preferredLocale = "preferred_locale"
            case surname
            case name
        }
    }
    
    struct DatasItemData: Codable {
        let objectType: String
        let displayName: String
        let value: String
    }
    
    struct AssertionsData: Codable {
        let objectType: String
        let items: [AssertionItemData]
        let totalItems: Int
    }
    
    struct AssertionItemData: Codable {
        let objectType: String
        let type: String
        let typology: String
        let mandatory: Bool
        let value: Bool
    }
    
}

