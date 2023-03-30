//
//  LoginRequestData.swift
//  
//
//  Created on 11/1/23.
//

import Foundation

struct LoginRequestData: Encodable {
    let actor: ActorData
    let verb: String = "access"
    let object: ObjectData
    let source: SourceData
    let context: ContextData?

    init(clientId: String, email: String, password: String) {
        self.actor = .init(id: clientId)
        self.object = .init(password: password, ids: .init(email: .init(value: email), facebookId: nil, appleId: nil))
        self.source = .init()
        self.context = nil
    }
    
    init(clientId: String, facebookUserId: String, token: String, tokenExpirationDate: Date?, email: String?, name: String?, birthday: Date?) {
        self.actor = .init(id: clientId)
        self.object = .init(password: nil, ids: .init(email: nil, facebookId: .init(value: facebookUserId), appleId: nil))
        self.source = .init()
        self.context = .init(
            accessToken: .init(value: token, expiresAt: tokenExpirationDate),
            profile: .init(email: email, name: name, birthday: birthday)
        )
    }
    
    init(clientId: String, appleUserId: String, token: String, tokenExpirationDate: Date?, email: String?, name: String?, birthday: Date?) {
        self.actor = .init(id: clientId)
        self.object = .init(password: nil, ids: .init(email: nil, facebookId: nil, appleId: .init(value: appleUserId)))
        self.source = .init()
        self.context = .init(
            accessToken: .init(value: token, expiresAt: tokenExpirationDate),
            profile: .init(email: email, name: name, birthday: birthday)
        )
    }
    
    init(clientId: String, email: String, password: String, facebookId: IdItemData?, appleId: IdItemData?, context: ContextData?) {
        self.actor = .init(id: clientId)
        self.object = .init(password: password, ids: .init(email: .init(value: email), facebookId: facebookId, appleId: appleId))
        self.source = .init()
        self.context = context
    }
    
    enum CodingKeys: String, CodingKey {
        case actor
        case verb
        case object
        case source
        case context
    }
}

extension LoginRequestData {
    
    struct ActorData: Encodable {
        let id: String
        let objectType: String = "application"
    }
    
    struct ObjectData: Encodable {
        let objectType: String = "user"
        let password: String?
        let ids: IdsData
    }
    
    struct IdsData: Encodable {
        let email: IdItemData?
        let facebookId: IdItemData?
        let appleId: IdItemData?

        enum CodingKeys: String, CodingKey {
            case email
            case facebookId = "facebook_id"
            case appleId = "apple_id"
        }
    }
    
    struct IdItemData: Encodable {
        let objectType: String = "user_id"
        let value: String
    }
    
    struct SourceData: Encodable {
        let id: String = "mobile"
        let objectType: String = "device"
    }
    
}
