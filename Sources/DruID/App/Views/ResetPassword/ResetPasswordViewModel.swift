import SwiftUI

protocol ResetPasswordNavigator {
    func dismissResetPassword()
}

@MainActor
class ResetPasswordViewModel: ResetPasswordVM {
    
    @Published private (set) var loading: Bool = false
    @Published var alert: AlertUIModel? = nil
    
    @Published var imageData: ImageData? = nil
    @Published var username: String = ""
    @Published private(set) var usernameError: String = ""
    
    private (set) var entryPointSettings: EntrypointSettingsResponseData? = nil

    private let navigator: ResetPasswordNavigator
    
    init(
        navigator: ResetPasswordNavigator,
        entryPointSettings: EntrypointSettingsResponseData? = nil
    ) {
        self.navigator = navigator
        
        self.entryPointSettings = entryPointSettings
        if let imageBase64String = entryPointSettings?.content.image?.data,
           let data = Data(base64Encoded: imageBase64String) {
            self.imageData = ImageData(data: data)
        }
    }

    func handle(event: ResetPasswordEvent) {
        switch event {
        case .onAppear: break
        case .sendButtonPressed:
            guard isValid() else { return }
            sendResetPassword()
        case .cancelButtonPressed:
            cancelButtonPressed()
        }
    }
    
    private func isValid() -> Bool {
        var isValid = true
        
        let emailRegex = "[_A-Za-z0-9-+]+(?:\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(?:\\.[A-Za-z0-9]+)*(?:\\.[A-Za-z]{2,})"

        if username.isEmpty {
            usernameError = Strings.common_mandatory_text
            isValid = false
        } else if !username.matches(emailRegex) {
            usernameError = Strings.common_invalid_email_text
        } else {
            usernameError = ""
        }
        
        return isValid
    }
    
    private func sendResetPassword() {
        let clientId = DruID.shared.dependencyManager?.keychainDataSource.settings?.clientId
        guard let clientId = clientId else { fatalError(DruID.sdkNotInitializedError) }
        
        let request: PasswordResetRequestData = .init(clientId: clientId, email: username)
        
        loading = true
        Task { [weak self] in
            do {
                let response = try await DruID.shared.dependencyManager?.repository.passwordResetRequest(request: request)
                self?.loading = false
                if let response = response {
                    if let error = response.result.errors?.first {
                        alert = .init(title: error.message)
                    } else {
                        alert = .init(title: Strings.reset_password_success_text, action: .default(title: Strings.common_accept_text, action: { [weak self] in
                            self?.navigator.dismissResetPassword()
                        }))
                    }
                }
            } catch {
                self?.loading = false
                alert = .init(error: error)
            }
        }
    }
    
    private func cancelButtonPressed() {
        navigator.dismissResetPassword()
    }
}
