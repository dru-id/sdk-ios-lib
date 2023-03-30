//
//  DruIdSettings.swift
//  
//
//  Created on 10/1/23.
//

import Foundation

public struct DruIdSettings: Codable {
    public let authBaseURL: String
    public let graphBaseURL: String
    public let clientId: String
    public let clientSecret: String
    public let entryPointId: String
    public let colorModel: ColorModel?
    public let logLevel: DruidLogLevel

    public init(
        authBaseURL: String,
        graphBaseURL: String,
        clientId: String,
        clientSecret: String,
        entryPointId: String,
        colorModel: ColorModel? = nil,
        logLevel: DruidLogLevel = .error
    ) {
        self.authBaseURL = authBaseURL
        self.graphBaseURL = graphBaseURL
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.entryPointId = entryPointId
        self.colorModel = colorModel
        self.logLevel = logLevel
    }
}
