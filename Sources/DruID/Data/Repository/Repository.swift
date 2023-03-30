//
//  Repository.swift
//  
//
//  Created on 9/1/23.
//

import Foundation

public final class Repository {
    
    private let apiDataSource: APIDataSource

    init(authBaseURL: String,  graphBaseURL: String) {
        self.apiDataSource = APIDataSource(authBaseURL: authBaseURL,  graphBaseURL: graphBaseURL)
    }
    
    func obtainClientToken() async throws -> ClientTokenData {
        return try await apiDataSource.obtainClientToken()
    }
    
    func searchEntrypointByObjetId() async throws -> EntrypointSettingsResponseData? {
        return try await apiDataSource.searchEntrypointByObjetId()
    }
    
    func login(request: LoginRequestData) async throws -> LoginResponseData {
        return try await apiDataSource.login(request: request)
    }
    
    func isUserConnected() async -> LoginResponseData? {
        if let oldLoginResponse = DruID.shared.dependencyManager?.keychainDataSource.loginResponse {
            do {
                if let oldSessionInfo = oldLoginResponse.content?.sessionInfo, oldSessionInfo.isValid() {
                    return try await getUpdatedLoginResponse(sessionInfo: oldSessionInfo)
                }
                let sessionInfo = try await refreshAccessToken()
                guard let sessionInfo = sessionInfo else { return nil }
                return try await getUpdatedLoginResponse(sessionInfo: sessionInfo)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func refreshAccessToken() async throws -> SessionInfoData? {
        return try await apiDataSource.refreshAccessToken()
    }
    
    func me() async throws -> LoginResponseData {
        return try await apiDataSource.me()
    }
    
    func register(request: RegisterRequestData) async throws -> RegisterResponseData {
        return try await apiDataSource.register(request: request)
    }
    
    func passwordResetRequest(request: PasswordResetRequestData) async throws -> PasswordResetResponseData {
        return try await apiDataSource.passwordResetRequest(request: request)
    }
    
    func acceptTermsAfterLogin(request: AcceptTermsAfterLoginRequest) async throws -> AcceptTermsAfterLoginResponse {
        return try await apiDataSource.acceptTermsAfterLogin(request: request)
    }
    
    // MARK: -  private
    
    private func getUpdatedLoginResponse(sessionInfo: SessionInfoData) async throws -> LoginResponseData {
        let savedLoginResponse = DruID.shared.dependencyManager?.keychainDataSource.loginResponse
        let meLoginResponse = try await me()
        return updateSessionInfo(sessionInfo: sessionInfo, savedLoginResponse: savedLoginResponse, meLoginResponse: meLoginResponse)
    }
    
    private func updateSessionInfo(
        sessionInfo: SessionInfoData,
        savedLoginResponse: LoginResponseData?,
        meLoginResponse: LoginResponseData
    ) -> LoginResponseData {
        // Keep some info from original login response
        let mergedSessionInfo: SessionInfoData = .init(
            accessToken: sessionInfo.accessToken,
            tokenType: sessionInfo.tokenType,
            expiresIn: sessionInfo.expiresIn,
            expiresAt: sessionInfo.expiresAt,
            refreshToken: sessionInfo.refreshToken,
            loginStatus: sessionInfo.loginStatus,
            scope: savedLoginResponse?.content?.sessionInfo?.scope,
            links: savedLoginResponse?.content?.sessionInfo?.links
        )
        return LoginResponseData.init(
            content: .init(
                user: meLoginResponse.content?.user,
                sessionInfo: mergedSessionInfo
            ),
            result: meLoginResponse.result
        )
    }
}
