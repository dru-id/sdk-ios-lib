//
//  File.swift
//  
//
//  Created on 7/2/23.
//

import Foundation

struct RegisterRequestData: Encodable {
    let actor: ActorData
    let verb: String = "create"
    let object: ObjectData
    let source: SourceData
    let context: ContextData?
    
    init(
        clientId: String,
        password: String?,
        ids: [String:Dictionary<String, AnyEncodable>],
        datas: [String:Dictionary<String, AnyEncodable>],
        assertions: [AssertionItemData],
        context: ContextData?
    ) {
        self.actor = .init(id: clientId)
        let assertions: AssertionsData = .init(items: assertions, totalItems: assertions.count)
        self.object = .init(password: password, ids: ids, datas: datas, assertions: assertions)
        self.source = .init()
        self.context = context
    }
}

extension RegisterRequestData {
    
    struct ActorData: Encodable {
        let id: String
        let objectType: String = "application"
    }
    
    struct ObjectData: Encodable {
        let objectType: String = "user"
        let password: String?
        let ids: [String:Dictionary<String, AnyEncodable>]
        let datas: [String:Dictionary<String, AnyEncodable>]
        let assertions: AssertionsData
    }
    
    struct AssertionsData: Encodable {
        let objectType: String = "assertions"
        let items: [AssertionItemData]
        let totalItems: Int
    }
    
    struct AssertionItemData: Encodable {
        let objectType: String = "assertion"
        let type: String
        let typology: String
        let value: String
    }
    
    struct SourceData: Encodable {
        let id: String = "mobile"
        let objectType: String = "device"
    }
    
}
