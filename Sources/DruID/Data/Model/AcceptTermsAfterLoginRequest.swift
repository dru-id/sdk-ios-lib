//
//  AcceptTermsAfterLoginRequest.swift
//  
//
//  Created on 22/2/23.
//

import Foundation

struct AcceptTermsAfterLoginRequest: Encodable {
    let actor: ActorData
    let verb: String = "accept"
    let object: ObjectData
    let context: ContextData?
    let source: SourceData
    
    init(
        clientId: String,
        email: String?,
        password: String?,
        facebookUserId: String?,
        appleUserId: String?,
        assertions: [AssertionItemData],
        context: ContextData?
    ) {
        self.actor = .init(id: clientId)
        let assertions: AssertionsData = .init(items: assertions, totalItems: assertions.count)
        var emailId: IdItemData? = nil
        if let email = email {
           emailId = .init(value: email)
        }
        var facebookId: IdItemData? = nil
        if let facebookUserId = facebookUserId {
            facebookId = .init(value: facebookUserId)
        }
        var appleId: IdItemData? = nil
        if let appleUserId = appleUserId {
            appleId = .init(value: appleUserId)
        }
        self.object = .init(password: password, ids: .init(email: emailId, facebookId: facebookId, appleId: appleId), assertions: assertions)
        self.context = context
        self.source = .init()
    }
}

extension AcceptTermsAfterLoginRequest {
    
    struct ActorData: Encodable {
        let id: String
        let objectType: String = "application"
    }
    
    struct ObjectData: Encodable {
        let objectType: String = "user"
        let password: String?
        let ids: IdsData
        let assertions: AssertionsData
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
    
    struct AssertionsData: Encodable {
        let objectType: String = "assertions"
        let items: [AssertionItemData]
        let totalItems: Int
    }
    
    struct AssertionItemData: Encodable {
        let objectType: String = "assertion"
        let type: String
        let value: Bool
    }
    
    struct SourceData: Encodable {
        let id: String = "mobile"
        let objectType: String = "device"
    }
    
}
