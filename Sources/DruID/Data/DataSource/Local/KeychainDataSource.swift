//
//  KeychainDataSource.swift
//  
//
//  Created on 11/1/23.
//

import Foundation

class KeychainDataSource {
    
    let account: String
        
    init(clientId: String) {
        self.account = clientId
    }
    
    var settings: DruIdSettings? {
        get { KeychainHelper.shared.read(key: .settings, account: account) }
        set { KeychainHelper.shared.save(newValue, key: .settings, account: account) }
    }
    
    var clientTokenData: ClientTokenData? {
        get { KeychainHelper.shared.read(key: .clientTokenData, account: account) }
        set { KeychainHelper.shared.save(newValue, key: .clientTokenData, account: account) }
    }
    
    var loginResponse: LoginResponseData? {
        get { KeychainHelper.shared.read(key: .loginResponse, account: account) }
        set { KeychainHelper.shared.save(newValue, key: .loginResponse, account: account) }
    }
    
    var entrypointSettings: EntrypointSettingsResponseData? {
        get { KeychainHelper.shared.read(key: .entrypointSettings, account: account) }
        set { KeychainHelper.shared.save(newValue, key: .entrypointSettings, account: account) }
    }
    
    public func reset() {
        KeychainHelper.shared.reset(account: account)
    }
}
