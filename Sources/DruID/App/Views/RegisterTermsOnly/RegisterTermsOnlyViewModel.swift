import SwiftUI

protocol RegisterTermsOnlyNavigator {
    func dismissRegisterTermsOnly()
}

@MainActor
class RegisterTermsOnlyViewModel: RegisterTermsOnlyVM {
    
    @Published private (set) var loading: Bool = false
    @Published var alert: AlertUIModel? = nil
    @Published var imageData: ImageData? = nil
    
    private let navigator: RegisterTermsOnlyNavigator
    private var loginRequest: LoginRequestData?
    private (set) var entryPointSettings: EntrypointSettingsResponseData? = nil
    private (set) var dynamicFormViewModel: DynamicFormViewModel? = nil
    private let termsCallback: (Result<AcceptTermsAfterLoginResponse, DruidError>) -> Void
    
    init(
        navigator: RegisterTermsOnlyNavigator,
        loginRequest: LoginRequestData?,
        entryPointSettings: EntrypointSettingsResponseData? = nil,
        termsCallback: @escaping (Result<AcceptTermsAfterLoginResponse, DruidError>) -> Void
    ) {
        self.navigator = navigator
        self.loginRequest = loginRequest
        self.entryPointSettings = entryPointSettings
        if let imageBase64String = entryPointSettings?.content.image?.data,
           let data = Data(base64Encoded: imageBase64String) {
            self.imageData = ImageData(data: data)
        }
        self.termsCallback = termsCallback
        
        initDynamicForm()
    }
    
    func handle(event: RegisterTermsOnlyEvent) {
        switch event {
        case .onAppear: break
        case .sendButtonPressed:
            guard isValid() else { return }
            sendAssertions()
        case .cancelButtonPressed:
            cancelButtonPressed()
        }
    }
    
    private func initDynamicForm() {
        dynamicFormViewModel = DynamicFormViewModel(
            items: nil,
            assertions: entryPointSettings?.content.assertions.items
        ) { [weak self] in
            self?.sendAssertions()
        }
    }
    
    private func isValid() -> Bool {
        return dynamicFormViewModel?.isValid() == true
    }
    
    private func sendAssertions() {
        let clientId = DruID.shared.dependencyManager?.keychainDataSource.settings?.clientId
        guard let clientId = clientId else { fatalError(DruID.sdkNotInitializedError) }
        
        let email = loginRequest?.object.ids.email?.value
        let password = loginRequest?.object.password
        let facebookId = loginRequest?.object.ids.facebookId?.value
        let appleId = loginRequest?.object.ids.appleId?.value
        let assertions: [AcceptTermsAfterLoginRequest.AssertionItemData] = dynamicFormViewModel?.items
            .compactMap {
                guard let assertion = $0.assertion else { return nil }
                return AcceptTermsAfterLoginRequest.AssertionItemData(type: assertion.type, value: $0.assertionValue)
            } ?? []
        
        let request: AcceptTermsAfterLoginRequest = .init(clientId: clientId, email: email, password: password, facebookUserId: facebookId, appleUserId: appleId, assertions: assertions, context: loginRequest?.context)
        
        loading = true
        Task { [weak self] in
            do {
                let response = try await DruID.shared.dependencyManager?.repository.acceptTermsAfterLogin(request: request)
                if let response = response {
                    if let errors = response.result.errors, !errors.isEmpty, let error = errors.first {
                        self?.alert = .init(title: error.message)
                    } else {
                        // Success
                        self?.termsCallback(.success(response))
                    }
                }
                self?.loading = false
            } catch {
                self?.loading = false
                self?.alert = .init(error: error)
            }
        }
    }
    
    private func cancelButtonPressed() {
        navigator.dismissRegisterTermsOnly()
    }
}

