import SwiftUI

protocol LinkAccountNavigator {
    func dismissLinkAccount()
}

@MainActor
class LinkAccountViewModel: LinkAccountVM {
    
    @Published private (set) var loading: Bool = false
    @Published var alert: AlertUIModel? = nil
    
    @Published var password: String = ""    
    @Published private(set) var passwordError: String = ""
    
    private var passwordSetCallback: (String) -> Void
    
    private let navigator: LinkAccountNavigator
    
    init(navigator: LinkAccountNavigator, passwordSetCallback: @escaping (String) -> Void) {
        self.navigator = navigator
        self.passwordSetCallback = passwordSetCallback
    }

    func handle(event: LinkAccountEvent) {
        switch event {
        case .onAppear: break
        case .syncButtonPressed:
            syncButtonPressed()
        case .cancelButtonPressed:
            cancelButtonPressed()
        }
    }
    
    private func validate() -> Bool {
        var valid = true
    
        if password.isEmpty {
            passwordError = Strings.common_mandatory_text
            valid = false
        } else {
            passwordError = ""
        }
        return valid
    }
    
    private func syncButtonPressed() {
        guard validate() else { return }
        
        passwordSetCallback(password)
    }
    
    private func cancelButtonPressed() {
        navigator.dismissLinkAccount()
    }
}
