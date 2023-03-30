//
//  DependencyManager.swift
//  
//
//  Created on 10/1/23.
//

import Foundation

class DependencyManager {
    
    let repository: Repository
    let keychainDataSource: KeychainDataSource

    init(settings: DruIdSettings) {
        
        repository = Repository(authBaseURL: settings.authBaseURL,  graphBaseURL: settings.graphBaseURL)

        keychainDataSource = KeychainDataSource(clientId: settings.clientId)
        
        keychainDataSource.settings = settings

    }
}
