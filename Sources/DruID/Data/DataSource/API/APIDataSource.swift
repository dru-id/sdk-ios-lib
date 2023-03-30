//
//  APIDataSource.swift
//
//
//  Created on 9/1/23.
//

import Foundation

final class APIDataSource {
    
    private let authBaseURL: String
    private let graphBaseURL: String
    
    private lazy var clientAuthManager: ClientAuthManager =
        ClientAuthManager(obtainNewClientToken: { [weak self] in
            try await self?.obtainClientToken()
        })
    
    private lazy var userAuthManager: UserAuthManager =
        UserAuthManager(refresToken: { [weak self] in
            try await self?.refreshAccessToken()
        })
    
    enum Endpoint: String {
        case authToken = "/oauth2/token"
        case login = "/activityid/v1/user/access"
        case me = "/activityid/v1/user/me"
        case searchEntrypointByObjetId = "/activityid/v1/entrypoint/{entrypoint_id}"
        case register = "/activityid/v1/user/create"
        case passwordResetRequest = "/activityid/v1/notification/request"
        case acceptAssertions = "/activityid/v1/assertions/accept"

        func url(baseUrl: String) -> String {
            return baseUrl + rawValue
        }
    }
    
    init(authBaseURL: String,  graphBaseURL: String) {
        self.authBaseURL = authBaseURL
        self.graphBaseURL = graphBaseURL
    }
    
    // MARK:- API calls
    
    /**
     *  The Client Token is a type of token that will allow the client application (Client) to access certain protected resources, request access to the login, register pages, etc.
     *
     *  The valid period of a Client Token is 1600 seconds (1 hour). If a Client Token has expired, a new one must be requested.
     */
    func obtainClientToken() async throws -> ClientTokenData {
        let settings = DruID.shared.dependencyManager?.keychainDataSource.settings
        guard let settings = settings else { fatalError(DruID.sdkNotInitializedError) }
        let request = ObtainClientTokenRequestData(clientId: settings.clientId, clientSecret: settings.clientSecret)
        let response: ClientTokenData = try await API.loadData(url: Endpoint.authToken.url(baseUrl: authBaseURL), method: .POST, body: request).decoded()
        DruID.shared.dependencyManager?.keychainDataSource.clientTokenData = response
        return response
    }
    
    func searchEntrypointByObjetId() async throws -> EntrypointSettingsResponseData {
        let entryPointId = DruID.shared.dependencyManager?.keychainDataSource.settings?.entryPointId
        guard let entryPointId = entryPointId else { fatalError(DruID.sdkNotInitializedError) }
        let headers = ["From" : entryPointId]
        let url = Endpoint.searchEntrypointByObjetId.url(baseUrl: graphBaseURL).replacingOccurrences(of: "{entrypoint_id}", with: entryPointId)
        let response: EntrypointSettingsResponseData = try await API.loadDataWithClientToken(url: url, method: .GET, headers: headers, clientAuthManager: clientAuthManager).decoded()
        DruID.shared.dependencyManager?.keychainDataSource.entrypointSettings = response
        return response
    }
    
    /**
     *  You have to call this method when you want to log in an user in your application with DRUID.
     *
     *  If you successfully log in an user in DRUID, you will receive an access_token (that you could use to call other resources that need an user session); you also get all information of the logged user.
     */
    func login(request: LoginRequestData) async throws -> LoginResponseData {
        let entryPointId = DruID.shared.dependencyManager?.keychainDataSource.settings?.entryPointId
        guard let entryPointId = entryPointId else { fatalError(DruID.sdkNotInitializedError) }
        let headers = ["From" : entryPointId]
        let response: LoginResponseData = try await API.loadDataWithClientToken(url: Endpoint.login.url(baseUrl: graphBaseURL), method: .POST, body: request, headers: headers, clientAuthManager: clientAuthManager).decoded()
        DruID.shared.dependencyManager?.keychainDataSource.loginResponse = response
        return response
    }
    
    /**
     *  If the client application needs to access an authenticated user’s private data, but the access_token is no longer valid, it must make a request to refresh the Access Token to get a new valid token relating to the user.
     *
     *  Remember that "Access token" is different from "Client token"
     */
    func refreshAccessToken() async throws -> SessionInfoData? {
        let settings = DruID.shared.dependencyManager?.keychainDataSource.settings
        guard let settings = settings else { fatalError(DruID.sdkNotInitializedError) }
        let refreshToken = DruID.shared.dependencyManager?.keychainDataSource.loginResponse?.content?.sessionInfo?.refreshToken
        guard let refreshToken = refreshToken else {
            DruidLogHelper.shared.log(.error, message: "User not logged in before. No refresh token stored previously.")
            return nil
        }
        let request = RefreshAccessTokenRequestData(clientId: settings.clientId, clientSecret: settings.clientSecret, refreshToken: refreshToken)
        return try await API.loadData(url: Endpoint.authToken.url(baseUrl: authBaseURL), method: .POST, body: request).decoded()
    }
    
    /**
     *  Obtain updated user data
     *
     */
    func me() async throws -> LoginResponseData {
        let settings = DruID.shared.dependencyManager?.keychainDataSource.settings
        guard let settings = settings else { fatalError(DruID.sdkNotInitializedError) }
        let entryPointId = settings.entryPointId
    
        var headers = ["From" : entryPointId]
        headers["From-Origin"] = settings.clientId
        return try await API.loadDataWithAccessToken(url: Endpoint.me.url(baseUrl: graphBaseURL), method: .GET, headers: headers, userAuthManager: userAuthManager).decoded()
    }
    
    /**
     *  You have to call this method when you want create a new user in DRUID.
     *
     *  As you know, DRUID defines a set of mandatory data for registration depending of the entry point you are using;
     *  be aware that if you send more data than defined in minimal register configuration, not needed data will be discarded and it will be not persisted nor validated.
     */
    func register(request: RegisterRequestData) async throws -> RegisterResponseData {
        let entryPointId = DruID.shared.dependencyManager?.keychainDataSource.settings?.entryPointId
        guard let entryPointId = entryPointId else { fatalError(DruID.sdkNotInitializedError) }
        let headers = ["From" : entryPointId]
        let response: RegisterResponseData = try await API.loadDataWithClientToken(url: Endpoint.register.url(baseUrl: graphBaseURL), method: .POST, body: request, headers: headers, clientAuthManager: clientAuthManager).decoded()
        return response
    }
    
    /**
     *  You have to call this method when the user ask for remembering his password.
     *  If the process it’s done successfully the user will receive a notification with a code and link to reset the current password and change it by a new one.
     *  The notification is sent by mail or sms (depending on the principal id defined with this app and entry point).
     */
    func passwordResetRequest(request: PasswordResetRequestData) async throws -> PasswordResetResponseData {
        let entryPointId = DruID.shared.dependencyManager?.keychainDataSource.settings?.entryPointId
        guard let entryPointId = entryPointId else { fatalError(DruID.sdkNotInitializedError) }
        let headers = ["From" : entryPointId]
        let response: PasswordResetResponseData = try await API.loadDataWithClientToken(url: Endpoint.passwordResetRequest.url(baseUrl: graphBaseURL), method: .POST, body: request, headers: headers, clientAuthManager: clientAuthManager).decoded()
        return response
    }
    
    /**
     *  You should call this method after you have made a social login in DRUID and you are required to accept the Terms & Conditions.
     *  If you need to know which T&Cs are to be accepted, you can make a call to consult the information about the entrypoint, its fields and consents to be accepted.
     *  After that, use the access token of the social login and make the call.
     */
    func acceptTermsAfterLogin(request: AcceptTermsAfterLoginRequest) async throws -> AcceptTermsAfterLoginResponse {
        let entryPointId = DruID.shared.dependencyManager?.keychainDataSource.settings?.entryPointId
        guard let entryPointId = entryPointId else { fatalError(DruID.sdkNotInitializedError) }
        let headers = ["From" : entryPointId]
        let response: AcceptTermsAfterLoginResponse = try await API.loadDataWithClientToken(url: Endpoint.acceptAssertions.url(baseUrl: graphBaseURL), method: .POST, body: request, headers: headers, clientAuthManager: clientAuthManager).decoded()
        return response
    }
}


