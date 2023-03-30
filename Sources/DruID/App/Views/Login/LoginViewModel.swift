import SwiftUI
import AuthenticationServices
import FacebookLogin

protocol LoginNavigator {
    func openLinkAccountView()
}

@MainActor
class LoginViewModel: BaseSocialLoginViewModel, LoginVM, ObservableObject {
    
    @Published private (set) var loading: Bool = false
    @Published var alert: AlertUIModel? = nil
    
    @Published var password: String = ""
    @Published var username: String = ""

    @Published private(set) var usernameError: String = ""
    @Published private(set) var passwordError: String = ""
    
    @Published var showingLinkAccountView: Bool = false
    @Published var linkAccountPassword: String? = nil
    
    @Published var showingRegisterView: Bool = false
    @Published var showingResetPasswordView: Bool = false
    @Published var showingRegisterTermsOnlyView: Bool = false

    @Published var imageData: ImageData? = nil

    private let loginCallback:(Result<LoginResponseData, DruidError>) -> Void
    
    var latestSocialRequest: LoginRequestData? = nil
    var loginRequestForTermsError: LoginRequestData? = nil

    init(loginCallback:@escaping (Result<LoginResponseData, DruidError>) -> Void) {
        self.loginCallback = loginCallback
    }

    func handle(event: LoginEvent) {
        switch event {
        case .onAppear:
            loadData()
        case .facebookButtonPressed:
            loginWithFacebook()
        case .appleButtonPressed:
            handleAuthorizationAppleIDButtonPress()
        case .forgotPasswordButtonPressed:
            openResetPassword()
        case .loginButtonPressed:
            guard isValid() else { return }
            loginWithUsernameAndPassword()
        case .registerButtonPressed:
            openRegisterUser()
        case .onRegistered:
            registered()
        case .onLoggedFromRegister(let result):
            loggedFromRegister(result)
        case .onLinkAccountWith(let password):
            linkAccountWith(password: password)
        case .onTermsOnlyResult(let result):
            onTermsOnlyResult(result)
        }
    }
    
    private func isValid() -> Bool {
        var valid = true
        
        let emailRegex = "[_A-Za-z0-9-+]+(?:\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(?:\\.[A-Za-z0-9]+)*(?:\\.[A-Za-z]{2,})"
        
        if username.isEmpty {
            usernameError = Strings.common_mandatory_text
            valid = false
        } else if !username.matches(emailRegex) {
            usernameError = Strings.common_invalid_email_text
        } else {
            usernameError = ""
        }
        
        if password.isEmpty {
            passwordError = Strings.common_mandatory_text
            valid = false
        } else {
            passwordError = ""
        }
        
        return valid
    }
    
    private func loadData() {
        loading = true
        Task { [weak self] in
            do {
                let clientTokenData = try await DruID.shared.dependencyManager?.repository.obtainClientToken()
                guard clientTokenData != nil else {
                    self?.loading = false
                    alert = .init(error: APIError.sdkSettingsNotSet)
                    return
                }
                let entryPointSettings = try await DruID.shared.dependencyManager?.repository.searchEntrypointByObjetId()
                guard entryPointSettings != nil else {
                    self?.loading = false
                    alert = .init(error: APIError.sdkSettingsNotSet)
                    return
                }
                self?.loading = false
                if let errorMessage = entryPointSettings?.result.errors?.first?.details {
                    alert = .init(title: errorMessage)
                } else {
                    self?.entryPointSettings = entryPointSettings
                    if let imageBase64String = entryPointSettings?.content.image?.data,
                       let data = Data(base64Encoded: imageBase64String) {
                        self?.imageData = ImageData(data: data)
                    }
                }
            } catch {
                self?.loading = false
                alert = .init(error: error)
            }
        }
    }
    
    private func loginWithUsernameAndPassword() {
        guard isValid() else { return }

        let clientId = DruID.shared.dependencyManager?.keychainDataSource.settings?.clientId
        guard let clientId = clientId else { fatalError(DruID.sdkNotInitializedError) }
        
        login(request: .init(clientId: clientId, email: username, password: password))
    }
    
    override func onSocialLoginSuccess(request: LoginRequestData) {
        login(request: request)
    }
    
    private func login(request: LoginRequestData) {
        loading = true
        Task { [weak self] in
            do {                let response = try await DruID.shared.dependencyManager?.repository.login(request: request)
                self?.loading = false
                if let response = response {
                    if response.result.status == 451 {
                        // user must accept the terms and conditions
                        self?.loginRequestForTermsError = request
                        showingRegisterTermsOnlyView = true
                        
                    } else if response.result.status == 403 {
                        // user not registered in Druid
                        if request.object.ids.facebookId != nil || request.object.ids.appleId != nil {
                            self?.latestSocialRequest = request
                            self?.openRegisterUser()
                        } else if let errorMessage = response.result.errors?.first?.details {
                            alert = .init(title: errorMessage)
                        }
                    } else  if response.result.status == 426 {
                        // email already registered in Druid, need to link accounts
                        self?.latestSocialRequest = request
                        self?.openLinkAccountView()
                        
                    } else if let errorMessage = response.result.errors?.first?.details {
                        alert = .init(title: errorMessage)
                    } else {
                        self?.loginCallback(Result.success(response))
                    }
                } else {
                    self?.loginCallback(Result.failure(.settingsNotSet))
                }
            } catch {
                self?.loading = false
                alert = .init(error: error)
            }
        }
    }
    
    private func openRegisterUser() {
        showingRegisterView = true
    }
    
    private func linkAccountWith(password: String) {
        let facebookId = latestSocialRequest?.object.ids.facebookId
        let appleId = latestSocialRequest?.object.ids.appleId
        let context = latestSocialRequest?.context

        let clientId = DruID.shared.dependencyManager?.keychainDataSource.settings?.clientId
        guard let clientId = clientId else { fatalError(DruID.sdkNotInitializedError) }
        
        guard let email = context?.profile?.email  else {
            DruidLogHelper.shared.log(.error, message: "No email available to link account to")
            return
        }
        
        let request = LoginRequestData(clientId: clientId, email: email, password: password, facebookId: facebookId, appleId: appleId, context: context)
        
        login(request: request)
        
        showingLinkAccountView = false
    }
    
    func dismissLinkAccount() {
        showingLinkAccountView = false
    }
    
    func dismissRegister() {
        showingRegisterView = false
        // forget social info
        self.latestSocialRequest = nil
    }
    
    private func registered() {
        showingRegisterView = false
    }
    
    private func openResetPassword() {
        showingResetPasswordView = true
    }
    
    func dismissResetPassword() {
        showingResetPasswordView = false
    }
    
    private func loggedFromRegister(_ result: Result<LoginResponseData, DruidError>) {
        showingRegisterView = false // Just dismiss parent sheet login
        loginCallback(result)
    }
    
    func dismissTermsOnly() {
        showingRegisterTermsOnlyView = false
    }
    
    private func onTermsOnlyResult(_ result: Result<AcceptTermsAfterLoginResponse, DruidError>) {
        showingRegisterTermsOnlyView = false
        
        switch result {
        case .success(_):
            // try login again
            if let loginRequestForTermsError = loginRequestForTermsError {
                login(request: loginRequestForTermsError)
            }
        case .failure(let error):
            alert = .init(error: error)
        }
        loginRequestForTermsError = nil
        
    }
}

extension LoginViewModel: LoginNavigator {
    
    // MARK: - LoginNavigator
    
    func openLinkAccountView() {
        showingLinkAccountView = true
    }
    
}
