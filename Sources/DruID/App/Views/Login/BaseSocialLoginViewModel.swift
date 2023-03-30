//
//  BaseSocialLoginViewModel.swift
//  
//
//  Created on 31/1/23.
//

import Foundation
import FacebookLogin
import AuthenticationServices

@MainActor
class BaseSocialLoginViewModel: NSObject {
    
    @Published var entryPointSettings: EntrypointSettingsResponseData? = nil
    
    var socialData: SocialData? = nil
    
    func onSocialLoginSuccess(request: LoginRequestData) {
        preconditionFailure("This method must be overridden")
    }

    // MARK: - Facebook login
    
    func loginWithFacebook() {
        
        if let token = AccessToken.current, !token.isExpired {
            // User is logged
            loadFacebookProfileAndLoginDruid(token: token)
            return
        }
        
        if let facebookConfig = entryPointSettings?.content.social.items.first(where: { $0.provider == .facebook }) {
            let permissions = facebookConfig.scope?.split(separator: ",").map { String($0) } ?? ["email", "public_profile"]
            LoginManager().logIn(permissions: permissions, from: nil) { [weak self] (result, error) in
                
                if let error = error {
                    DruidLogHelper.shared.log(.error, message: "Facebook login: error: \(error)")
                    return
                }
                
                guard let result = result else {
                    DruidLogHelper.shared.log(.debug, message: "Facebook login: result is nil")
                    return
                }
                
                if result.isCancelled {
                    DruidLogHelper.shared.log(.debug, message: "Facebook login: cancelled")
                    return
                }
                
                guard let token = result.token else {
                    DruidLogHelper.shared.log(.debug, message: "Facebook login: token is nil")
                    return
                }
                
                DruidLogHelper.shared.log(.debug, message: "Facebook login: logged in")
                self?.loadFacebookProfileAndLoginDruid(token: token)
            }
        }
    }
    
    private func loadFacebookProfileAndLoginDruid(token: AccessToken) {
        let facebookUserId = token.userID
        let tokenString = token.tokenString
        let tokenExpirationDate = token.expirationDate
        
        Profile.loadCurrentProfile { [weak self] (profile, error) in
            let clientId = DruID.shared.dependencyManager?.keychainDataSource.settings?.clientId
            guard let clientId = clientId else { fatalError(DruID.sdkNotInitializedError) }
            
            let name = profile?.name
            let email = profile?.email
            let birthday = profile?.birthday
            
            self?.socialData = .init(id: facebookUserId, name: name, surname: profile?.lastName, birthday: birthday, token: tokenString, tokenExpirationDate: tokenExpirationDate)
            
            let request = LoginRequestData(clientId: clientId, facebookUserId: facebookUserId, token: tokenString, tokenExpirationDate: tokenExpirationDate, email: email, name: name, birthday: birthday)
            
            self?.onSocialLoginSuccess(request: request)
        }
        
    }
    
    // MARK: - Apple login
    
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    private func signInAppleUser(credential: ASAuthorizationAppleIDCredential) {
        // API Call - Pass the user identity, authorizationCode and identity token
        
        let clientId = DruID.shared.dependencyManager?.keychainDataSource.settings?.clientId
        guard let clientId = clientId else { fatalError(DruID.sdkNotInitializedError) }
        
        var tokenExpiration = Date()
        if let decodedJwt = try? credential.decode() {
            if let timestamp = decodedJwt["auth_time"] as? TimeInterval {
                tokenExpiration = Date(timeIntervalSince1970: timestamp)
            }
        }
        if let identityToken = credential.identityToken,
           let jwtToken = String(data: identityToken, encoding: .utf8) {
            let request = LoginRequestData(clientId: clientId, appleUserId: credential.user, token: jwtToken, tokenExpirationDate: tokenExpiration, email: credential.email, name: credential.nameFormatted(), birthday: nil)
            
            socialData = .init(id: credential.user, name: credential.fullName?.givenName, surname: credential.fullName?.familyName, birthday: nil, token: jwtToken, tokenExpirationDate: tokenExpiration)

            onSocialLoginSuccess(request: request)
        }
    }
    
    private func signInAppleUserWithUsernamePassword(credential: ASPasswordCredential) {
        // API Call - Sign in with username and password
        
        let clientId = DruID.shared.dependencyManager?.keychainDataSource.settings?.clientId
        guard let clientId = clientId else { fatalError(DruID.sdkNotInitializedError) }
        
        let request = LoginRequestData(clientId: clientId, appleUserId: credential.user, token: credential.password, tokenExpirationDate: nil, email: nil, name: nil, birthday: nil)
        
        socialData = .init(id: credential.user, name: nil, surname: nil, birthday: nil, token: credential.password, tokenExpirationDate: nil)

        
        onSocialLoginSuccess(request: request)
    }
    
}

extension BaseSocialLoginViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let email = appleIdCredential.email, let _ = appleIdCredential.fullName {
                // Apple has authorized the use with Apple ID and password
                signInAppleUser(credential: appleIdCredential)
                DruidLogHelper.shared.log(.debug, message: "ASAuthorizationControllerDelegate - registerd new user with email: (\(email))")
            } else {
                // User has been already exist with Apple Identity Provider
                signInAppleUser(credential: appleIdCredential)
                // Info: user, identityToken, authorizationCode
                DruidLogHelper.shared.log(.debug, message: "ASAuthorizationControllerDelegate - signed existing user: (\(appleIdCredential.user))")
            }
            break
            
        case let passwordCredential as ASPasswordCredential:
            // Info: user, password
            signInAppleUserWithUsernamePassword(credential: passwordCredential)
            DruidLogHelper.shared.log(.debug, message: "ASAuthorizationControllerDelegate - signed with user (\(passwordCredential.user)) and password")
            break
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DruidLogHelper.shared.log(.error, message: "ASAuthorizationControllerDelegate: \(error)")
    }
    
}

extension ASAuthorizationAppleIDCredential {
    
    func nameFormatted() -> String? {
        var name: String = ""
        if let givenName = fullName?.givenName, !givenName.isEmpty {
            name = givenName
        }
        if let familyName = fullName?.familyName, !familyName.isEmpty {
            if name.isEmpty {
                name = familyName
            } else {
                name += " " + familyName
            }
        }
        return name
    }
    
}
