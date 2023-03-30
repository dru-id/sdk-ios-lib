import SwiftUI

enum LoginEvent {
    case onAppear
    case facebookButtonPressed
    case appleButtonPressed
    case forgotPasswordButtonPressed
    case loginButtonPressed
    case registerButtonPressed
    case onRegistered
    case onLoggedFromRegister(Result<LoginResponseData, DruidError>)
    case onLinkAccountWith(String)
    case onTermsOnlyResult(Result<AcceptTermsAfterLoginResponse, DruidError>)
}

@MainActor
protocol LoginVM: ObservableObject {
    var loading: Bool { get }
    var alert: AlertUIModel? { get set }
    
    var password: String { get set }
    var username: String { get set }
    
    var usernameError: String { get }
    var passwordError: String { get }
    
    var showingLinkAccountView: Bool { get set }
    var linkAccountPassword: String? { get }
    
    var showingRegisterView: Bool { get set }
    var showingResetPasswordView: Bool { get set }
    var showingRegisterTermsOnlyView: Bool { get set }
    
    var imageData: ImageData? { get }
    
    var entryPointSettings: EntrypointSettingsResponseData? { get }
    var latestSocialRequest: LoginRequestData? { get }
    var loginRequestForTermsError: LoginRequestData? { get }
    var socialData: SocialData? { get }

    func handle(event: LoginEvent)
    func dismissLinkAccount()
    func dismissRegister()
    func dismissResetPassword()
    func dismissTermsOnly()
}

struct LoginView<ViewModel: LoginVM>: View {
    
    private enum FieldFocus { case username, password }
    
    @StateObject var viewModel: ViewModel
    @State private var focus: FieldFocus?
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var logoImage: Image {
        guard let image = viewModel.imageData?.image else {
            return Image("druid_logo", bundle: .module)
        }
        return Image(uiImage: image)
    }
    
    public var body: some View {
        
        ScrollView {
            VStack {
                VStack {
                    if viewModel.entryPointSettings != nil {
                        logoImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 170)
                            .padding(.bottom)
                    }
                    
                    HStack(spacing: .spacingM) {
                        if (viewModel.entryPointSettings?.canLoginWithFacebook == true) {
                            SocialButton(provider: .facebook) {
                                viewModel.handle(event: .facebookButtonPressed)
                            }
                        }
                        if (viewModel.entryPointSettings?.canLoginWithApple == true) {
                            SocialButton(provider: .apple) {
                                viewModel.handle(event: .appleButtonPressed)
                            }
                        }
                    }.padding(.bottom)
                    
                    TextFieldView(
                        title: Strings.login_username_title,
                        placeholder: Strings.login_username_placeholder,
                        error: viewModel.usernameError,
                        text: $viewModel.username
                    )
                    .backport.configureTextField(
                        contentType: .username,
                        submitLabel: .next,
                        focusState: $focus,
                        field: .username,
                        nextField: .password
                    )
                    .backport.textInputAutocapitalization(.never)
                    
                    SecureFieldView(
                        title: Strings.login_password_title,
                        placeholder: Strings.login_password_placeholder,
                        error: viewModel.passwordError,
                        text: $viewModel.password
                    )
                    .padding(.top)
                    .backport.configureTextField(
                        keyboard: .default,
                        submitLabel: .continue,
                        focusState: $focus,
                        field: .password
                    ) {
                        viewModel.handle(event: .loginButtonPressed)
                    }
                    
                    Button(Strings.login_forgot_password_button) {
                        viewModel.handle(event: .forgotPasswordButtonPressed)
                    }
                    .buttonStyle(.tertiary)
                    .padding(.init(top: .spacingM, leading: 0, bottom: .spacingM, trailing: 0))
                    
                    Button(Strings.login_login_button) {
                        viewModel.handle(event: .loginButtonPressed)
                    }.buttonStyle(.primary)
                }
                .padding(EdgeInsets(top: .spacingXL, leading: .spacingM, bottom: .spacingXL, trailing: .spacingM))
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.shadow, radius: 21)
                
                HStack {
                    Spacer()
                    Text(Strings.login_not_account_yet_text)
                        .foregroundColor(Color.white)
                        .font(.subheadline)
                    Button(Strings.login_register_button) {
                        viewModel.handle(event: .registerButtonPressed)
                    }.buttonStyle(.secondary)
                }
                .padding(.top)
            }
            .padding(.init(top: 0, leading: .spacingM, bottom: .spacingXL, trailing: .spacingM))
            .sheet(isPresented: $viewModel.showingLinkAccountView) {
                let viewModel = LinkAccountViewModel(navigator: self) { password in
                    self.viewModel.handle(event: .onLinkAccountWith(password))
                }
                LinkAccountView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingRegisterView) {
                let viewModel = RegisterViewModel(
                    navigator: self,
                    entryPointSettings: viewModel.entryPointSettings,
                    socialLoginRequestFromLoginView: viewModel.latestSocialRequest,
                    socialData: viewModel.socialData,
                    registerCallback: { _ in
                        self.viewModel.handle(event: .onRegistered)
                    },
                    registerAndLoggedInCallback: { result in
                        self.viewModel.handle(event: .onLoggedFromRegister(result))
                    }
                )
                RegisterView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingResetPasswordView) {
                let viewModel = ResetPasswordViewModel(navigator: self, entryPointSettings: viewModel.entryPointSettings)
                ResetPasswordView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingRegisterTermsOnlyView) {
                let viewModel = RegisterTermsOnlyViewModel(
                    navigator: self,
                    loginRequest: viewModel.loginRequestForTermsError,
                    entryPointSettings: viewModel.entryPointSettings
                ) { result in
                    self.viewModel.handle(event: .onTermsOnlyResult(result))
                }
                RegisterTermsOnlyView(viewModel: viewModel)
            }
        }
        .background(Color.partnerSecondary.ignoresSafeArea())
        .alert(model: $viewModel.alert)
        .loading(loading: viewModel.loading)
        .onAppear {
            viewModel.handle(event: .onAppear)
        }
    }
}

#if DEBUG
class MockLoginVM: LoginVM {
    
    @Published var alert: AlertUIModel? = nil
    var loading: Bool = false
    
    var password: String = ""
    var username: String = ""
    var usernameError: String = ""
    var passwordError: String = ""
    
    var showingLinkAccountView: Bool = false
    var linkAccountPassword: String? = nil
    var showingRegisterView: Bool = false
    var showingResetPasswordView: Bool = false
    var showingRegisterTermsOnlyView: Bool = false
    var imageData: ImageData? = nil
    var entryPointSettings: EntrypointSettingsResponseData? = EntrypointSettingsResponseData.mock()
    var latestSocialRequest: LoginRequestData? = nil
    var loginRequestForTermsError: LoginRequestData? = nil
    var socialData: SocialData? = nil
    
    func handle(event: LoginEvent) {
        switch event {
        case .onAppear: break
        case .facebookButtonPressed: break
        case .appleButtonPressed: break
        case .forgotPasswordButtonPressed: break
        case .loginButtonPressed: break
        case .registerButtonPressed: break
        case .onRegistered: break
        case .onLoggedFromRegister(_): break
        case .onLinkAccountWith(_): break
        case .onTermsOnlyResult(_): break
        }
    }
    
    func dismissLinkAccount() {}
    func dismissRegister() {}
    func dismissResetPassword() {}
    func dismissTermsOnly() {}
}

extension LoginView where ViewModel == MockLoginVM {
    static var mock: LoginView {
        return .init(viewModel: MockLoginVM())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView.mock
    }
}
#endif

extension LoginView: LinkAccountNavigator {
    func dismissLinkAccount() {
        viewModel.dismissLinkAccount()
    }
}

extension LoginView: RegisterNavigator {
    func dismissRegister() {
        viewModel.dismissRegister()
    }
}

extension LoginView: ResetPasswordNavigator {
    func dismissResetPassword() {
        viewModel.dismissResetPassword()
    }
}

extension LoginView: RegisterTermsOnlyNavigator {
    func dismissRegisterTermsOnly() {
        viewModel.dismissTermsOnly()
    }
}

