import SwiftUI

protocol RegisterNavigator {
    func dismissRegister()
}

@MainActor
class RegisterViewModel: BaseSocialLoginViewModel, RegisterVM {
    
    @Published private (set) var loading: Bool = false
    @Published var alert: AlertUIModel? = nil
    @Published var imageData: ImageData? = nil
    @Published var showingRegisterConfirmationView: Bool = false
    @Published var showingLinkAccountView: Bool = false
    @Published var showingRegisterTermsOnlyView: Bool = false
    @Published var preFilledFormWithSocialData: Bool = false

    var responseMessage: String = ""
    private var registerResponse: RegisterResponseData? = nil

    private let navigator: RegisterNavigator?
    private let registerCallback: (Result<RegisterResponseData, DruidError>) -> Void
    private let registerAndLoggedInCallback: (Result<LoginResponseData, DruidError>) -> Void
    private let onCancelButtonPressed: (() -> Void)?
    
    private (set) var dynamicFormViewModel: DynamicFormViewModel? = nil
    private var socialLoginRequestFromLoginView: LoginRequestData? = nil
    private (set) var latestSocialRequest: LoginRequestData? = nil
    private (set) var loginRequestForTermsError: LoginRequestData? = nil

    init(
        navigator: RegisterNavigator? = nil,
        entryPointSettings: EntrypointSettingsResponseData? = nil,
        socialLoginRequestFromLoginView: LoginRequestData? = nil,
        socialData: SocialData? = nil,
        onCancelButtonPressed: (() -> Void)? = nil,
        registerCallback:@escaping (Result<RegisterResponseData, DruidError>) -> Void,
        registerAndLoggedInCallback:@escaping (Result<LoginResponseData, DruidError>) -> Void
    ) {
        self.navigator = navigator
        self.onCancelButtonPressed = onCancelButtonPressed
        self.registerCallback = registerCallback
        self.registerAndLoggedInCallback = registerAndLoggedInCallback
        super.init()
        self.entryPointSettings = entryPointSettings
        
        loadLogo()
        
        initDynamicForm()
        
        if let socialData = socialData {
            self.socialData = socialData
        }
        
        if let socialLoginRequestFromLoginView = socialLoginRequestFromLoginView {
            fillFormWithSocialInfo(loginRequest: socialLoginRequestFromLoginView)
        }
    }
    
    func handle(event: RegisterEvent) {
        switch event {
        case .onAppear:
            loadData()
        case .facebookButtonPressed:
            loginWithFacebook()
        case .appleButtonPressed:
            handleAuthorizationAppleIDButtonPress()
        case .sendButtonPressed:
            guard isValid() else { return }
            registerWithForm()
        case .cancelButtonPressed:
            cancelButtonPressed()
        case .onCloseRegisterOnSuccess:
            closeRegisterOnSuccess()
        case .onLinkAccountWith(let password):
            linkAccountWith(password: password)
        case .onTermsOnlyResult(let result):
            onTermsOnlyResult(result)
        }
    }
    
    override func onSocialLoginSuccess(request: LoginRequestData) {
        login(request: request)
    }
    
    private func cancelButtonPressed() {
        self.latestSocialRequest = nil
        if showingRegisterConfirmationView {
            closeRegisterOnSuccess()
        } else {
            onCancelButtonPressed?()
            navigator?.dismissRegister()
        }
    }
    
    private func loadData() {
        guard entryPointSettings == nil else { return }
        
        loading = true
        Task { [weak self] in
            do {
                let clientTokenData = try await DruID.shared.dependencyManager?.repository.obtainClientToken()
                guard clientTokenData != nil else {
                    self?.loading = false
                    self?.alert = .init(error: APIError.sdkSettingsNotSet)
                    return
                }
                let entryPointSettings = try await DruID.shared.dependencyManager?.repository.searchEntrypointByObjetId()
                guard entryPointSettings != nil else {
                    self?.loading = false
                    self?.alert = .init(error: APIError.sdkSettingsNotSet)
                    return
                }
                self?.loading = false
                if let errorMessage = entryPointSettings?.result.errors?.first?.details {
                    self?.alert = .init(title: errorMessage)
                } else {
                    self?.entryPointSettings = entryPointSettings
                }
                
                self?.loadLogo()
                
                self?.initDynamicForm()
                
            } catch {
                self?.loading = false
                self?.alert = .init(error: error)
            }
        }
    }
    
    private func loadLogo() {
        if let imageBase64String = entryPointSettings?.content.image?.data,
           let data = Data(base64Encoded: imageBase64String) {
            self.imageData = ImageData(data: data)
        }
    }
    
    private func initDynamicForm() {
        guard let fields = entryPointSettings?.content.fields.items else { return }
        
        let sortedFields = fields.sorted(by: { $0.order < $1.order })
        dynamicFormViewModel = DynamicFormViewModel(
            items: sortedFields,
            assertions: entryPointSettings?.content.assertions.items
        ) { [weak self] in
            self?.registerWithForm()
        }
    }
    
    private func isValid() -> Bool {
        let isValid = dynamicFormViewModel?.isValid() == true
        if !isValid {
            alert = .init(title: Strings.register_validation_error_text)
        }
        return isValid
    }
    
    private func fillFormWithSocialInfo(loginRequest: LoginRequestData) {
        socialLoginRequestFromLoginView = loginRequest
        preFilledFormWithSocialData = true
        
        let email = loginRequest.context?.profile?.email

        dynamicFormViewModel?.items.forEach({ model in
            guard let fieldItem = model.fieldItem else { return }
            
            switch fieldItem.id {
            case "email":
                if let email = email {
                    model.inputValue = email
                    model.editable = false
                }
            case "name":
                if let name = socialData?.name {
                    model.inputValue = name
                }
            case "surname":
                if let surname = socialData?.surname {
                    model.inputValue = surname
                }
            case "birthday":
                if let birthday = socialData?.birthday {
                    model.dateToInputValueString(date: birthday)
                }
            default: break
            }
        })
    }
    
    private func login(request: LoginRequestData) {
        loading = true
        Task { [weak self] in
            do {
                let response = try await DruID.shared.dependencyManager?.repository.login(request: request)
                self?.loading = false
                if let response = response {
                    if response.result.status == 451 {
                        // user must accept the terms and conditions
                        self?.loginRequestForTermsError = request
                        self?.showingRegisterTermsOnlyView = true
                        
                    } else if response.result.status == 403 {
                        // user not registered in Druid: fill form and proceed with manual registration
                        self?.fillFormWithSocialInfo(loginRequest: request)
                        
                    } else  if response.result.status == 426 {
                        // email already registered in Druid, need to link accounts
                        self?.latestSocialRequest = request
                        self?.openLinkAccountView()
                        
                    } else if let errorMessage = response.result.errors?.first?.details {
                        self?.alert = .init(title: errorMessage)
                    } else {
                        // user successfully registered
                        self?.registerAndLoggedInCallback(Result.success(response))
                    }
                } else {
                    self?.registerAndLoggedInCallback(Result.failure(.settingsNotSet))
                }
            } catch {
                self?.loading = false
                self?.alert = .init(error: error)
            }
        }
    }
    
    private func registerWithForm() {
        let clientId = DruID.shared.dependencyManager?.keychainDataSource.settings?.clientId
        guard let clientId = clientId else { fatalError(DruID.sdkNotInitializedError) }
        
        var ids = [String:Dictionary<String, AnyEncodable>]()
        var datas = [String:Dictionary<String, AnyEncodable>]()
        var assertions = [RegisterRequestData.AssertionItemData]()
        var password: String? = nil
        var context: ContextData? = nil
        
        dynamicFormViewModel?.items.forEach({ model in
            if let fieldItem = model.fieldItem {
                switch fieldItem.field.objectType {
                case "user_data":
                    if let dictionary = model.toRequestDictionary() {
                        datas = datas.merging(dictionary) { (current,_) in current }
                    }
                case "password":
                    password = model.inputValue
                case "user_id":
                    if let dictionary = model.toRequestDictionary() {
                        ids = ids.merging(dictionary) { (current,_) in current }
                    }
                default: break
                }
            } else if let assertion = model.assertion {
                assertions += [
                    RegisterRequestData.AssertionItemData(
                        type: assertion.type,
                        typology: assertion.typology,
                        value: String(model.assertionValue)
                    )
                ]
            }
        })
        
        if let socialLoginRequest = socialLoginRequestFromLoginView {
            let facebookId = socialLoginRequest.object.ids.facebookId
            let appleId = socialLoginRequest.object.ids.appleId
            let email = socialLoginRequest.context?.profile?.email
            
            if let facebookId = facebookId {
                var dict: [String:AnyEncodable] = [:]
                dict["objectType"] = AnyEncodable(value: "user_id")
                dict["value"] = AnyEncodable(value: facebookId.value)
                ids["facebook_id"] = dict
            }
            if let appleId = appleId {
                var dict: [String:AnyEncodable] = [:]
                dict["objectType"] = AnyEncodable(value: "user_id")
                dict["value"] = AnyEncodable(value: appleId.value)
                ids["apple_id"] = dict
            }
            if let email = email {
                var dict: [String:AnyEncodable] = [:]
                dict["objectType"] = AnyEncodable(value: "user_id")
                dict["value"] = AnyEncodable(value: email)
                dict["confirmed"] = AnyEncodable(value: true)
                ids["email"] = dict
            }
            
            
            if let accessToken = socialLoginRequest.context?.accessToken.value {
                context = .init(accessToken: .init(value: accessToken, expiresAt: socialLoginRequest.context?.accessToken.expiresAt), profile: nil)
            }
        }
        
        let request: RegisterRequestData = .init(clientId: clientId, password: password, ids: ids, datas: datas, assertions: assertions, context: context)
        
        register(request: request)
    }
    
    private func register(request: RegisterRequestData) {
        loading = true
        Task { [weak self] in
            do {
                let response = try await DruID.shared.dependencyManager?.repository.register(request: request)
                self?.loading = false
                if let response = response {
                    if let errors = response.result.errors, !errors.isEmpty {
                        errors.forEach { errorData in
                            let formModel = self?.dynamicFormViewModel?.items.first(where: { model in
                                model.fieldItem?.id == errorData.message
                            })
                            if let formModel = formModel, let errorDetails = errorData.details {
                                formModel.inputError = errorDetails
                            }
                        }
                        self?.alert = .init(title: Strings.register_validation_error_text)
                    } else {
                        self?.registerResponse = response
                        if response.content?.confirmed == true {
                            // was registered using social login and email is already confirmed (no need to check email)
                            // auto login
                            if let request = self?.latestSocialRequest {
                                self?.login(request: request)
                            } else if let request = self?.socialLoginRequestFromLoginView {
                                self?.login(request: request)
                            } else {
                                self?.responseMessage = Strings.register_confirmation_sucess_already_confirmed_text
                                self?.showingRegisterConfirmationView = true
                            }
                        } else {
                            if response.result.status == 201 {
                                self?.responseMessage = Strings.register_confirmation_message_text
                            } else if response.result.status == 207 {
                                self?.responseMessage = Strings.register_confirmation_success_but_email_not_sent_text
                            }
                            self?.showingRegisterConfirmationView = true
                        }
                    }
                }
            } catch {
                self?.loading = false
                self?.alert = .init(error: error)
            }
        }
    }

    private func closeRegisterOnSuccess() {
        if let response = registerResponse {
            registerCallback(.success(response))
        }
    }
    
    private func openLinkAccountView() {
        showingLinkAccountView = true
    }
    
    func dismissLinkAccount() {
        showingLinkAccountView = false
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


