//
//  PasswordResetRequestData.swift
//  
//
//  Created on 17/2/23.
//

import Foundation

struct PasswordResetRequestData: Encodable {
    let actor: ActorData
    let verb: String = "request"
    let object: ObjectData
    let context: ContextData
    let source: SourceData
    
    init(clientId: String, email: String) {
        self.actor = .init(id: clientId)
        self.object = .init(ids: .init(email: .init(value: email)))
        self.context = .init()
        self.source = .init()
    }
}

extension PasswordResetRequestData {
    
    struct ActorData: Encodable {
        let id: String
        let objectType: String = "application"
    }
    
    struct ObjectData: Encodable {
        let objectType: String = "user"
        let ids: IdsData
    }
    
    struct IdsData: Encodable {
        let email: EmailData
    }
    
    struct EmailData: Encodable {
        let objectType: String = "user_id"
        let value: String
    }
    
    struct ContextData: Encodable {
        let notificationType: String = "reset_password"
    }
    
    struct SourceData: Encodable {
        let id: String = "mobile"
        let objectType: String = "device"
    }
    
}

