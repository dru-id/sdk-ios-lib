import SwiftUI

enum RegisterEvent {
    case onAppear
    case facebookButtonPressed
    case appleButtonPressed
    case sendButtonPressed
    case cancelButtonPressed
    case onCloseRegisterOnSuccess
    case onLinkAccountWith(String)
    case onTermsOnlyResult(Result<AcceptTermsAfterLoginResponse, DruidError>)
}

@MainActor
protocol RegisterVM: ObservableObject {
    var loading: Bool { get }
    var alert: AlertUIModel? { get set }
    var imageData: ImageData? { get }
    var showingRegisterConfirmationView: Bool { get set }
    var showingLinkAccountView: Bool { get set }
    var showingRegisterTermsOnlyView: Bool { get set }
    var preFilledFormWithSocialData: Bool { get }
    
    var responseMessage: String { get }
    var entryPointSettings: EntrypointSettingsResponseData? { get }
    var dynamicFormViewModel: DynamicFormViewModel? { get }
    var latestSocialRequest: LoginRequestData? { get }
    var loginRequestForTermsError: LoginRequestData? { get }
    
    func handle(event: RegisterEvent)
    func dismissLinkAccount()
    func dismissTermsOnly()
}

struct RegisterView<ViewModel: RegisterVM>: View {
        
    @StateObject var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var logoImage: Image {
        guard let image = viewModel.imageData?.image else {
            return Image("druid_logo", bundle: .module)
        }
        return Image(uiImage: image)
    }
    
    public var body: some View {
        
        NavigationView {
            ScrollView {
                if !viewModel.showingRegisterConfirmationView {
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
                                if (viewModel.entryPointSettings?.canLoginWithFacebook == true && viewModel.preFilledFormWithSocialData == false) {
                                    SocialButton(provider: .facebook) {
                                        viewModel.handle(event: .facebookButtonPressed)
                                    }
                                }
                                if (viewModel.entryPointSettings?.canLoginWithApple == true && viewModel.preFilledFormWithSocialData == false) {
                                    SocialButton(provider: .apple) {
                                        viewModel.handle(event: .appleButtonPressed)
                                    }
                                }
                            }.padding(.bottom)
                            
                            if let dynamicFormViewModel = viewModel.dynamicFormViewModel {
                                DynamicFormView(viewModel: dynamicFormViewModel)
                            }
                            
                            Button(Strings.register_send_button) {
                                viewModel.handle(event: .sendButtonPressed)
                            }
                            .buttonStyle(.primary)
                            .padding(.top)
                        }
                        .padding(EdgeInsets(top: .spacingXL, leading: .spacingM, bottom: .spacingXL, trailing: .spacingM))
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.shadow, radius: 21)
                        
                    }
                    .padding([.leading, .trailing], .spacingM)
                } else {
                    let viewModel = RegisterConfirmationViewModel(
                        entryPointSettings: viewModel.entryPointSettings,
                        message: viewModel.responseMessage
                    ) {
                        self.viewModel.handle(event: .onCloseRegisterOnSuccess)
                    }
                    RegisterConfirmationView(viewModel: viewModel)
                }
            }
            .background(Color.partnerSecondary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Strings.common_cancel_text) {
                        viewModel.handle(event: .cancelButtonPressed)
                    }
                    .foregroundColor(.white)
                }
            }
            .backport.toolbarBackground(Color.partnerSecondary, for: .navigationBar)
        }
        .alert(model: $viewModel.alert)
        .loading(loading: viewModel.loading)
        .onAppear {
            viewModel.handle(event: .onAppear)
        }
        .sheet(isPresented: $viewModel.showingLinkAccountView) {
            let viewModel = LinkAccountViewModel(navigator: self) { password in
                self.viewModel.handle(event: .onLinkAccountWith(password))
            }
            LinkAccountView(viewModel: viewModel)
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
}

#if DEBUG
class MockRegisterVM: RegisterVM {
    
    @Published var alert: AlertUIModel? = nil
    let loading: Bool = false
    var imageData: ImageData? = nil
    var responseMessage: String = Strings.register_confirmation_message_text
    var showingRegisterConfirmationView: Bool = false
    var showingLinkAccountView: Bool = false
    var showingRegisterTermsOnlyView: Bool = false
    var preFilledFormWithSocialData: Bool = false
    
    var entryPointSettings: EntrypointSettingsResponseData? = EntrypointSettingsResponseData.mock()
    var dynamicFormViewModel: DynamicFormViewModel? = nil
    var latestSocialRequest: LoginRequestData? = nil
    var loginRequestForTermsError: LoginRequestData? = nil
    var showCancelButton: Bool = true

    init() {
        if let imageBase64String = entryPointSettings?.content.image?.data,
           let data = Data(base64Encoded: imageBase64String) {
            imageData = ImageData(data: data)
        }
        dynamicFormViewModel = .init(
            items: entryPointSettings?.content.fields.items,
            assertions: entryPointSettings?.content.assertions.items,
            sendCallback: {
                // Does nothing
            })
    }
    
    func handle(event: RegisterEvent) {
        switch event {
        case .onAppear: break
        case .facebookButtonPressed: break
        case .appleButtonPressed: break
        case .sendButtonPressed:
            _ = dynamicFormViewModel?.isValid()
        case .cancelButtonPressed: break
        case .onCloseRegisterOnSuccess: break
        case .onLinkAccountWith(_): break
        case .onTermsOnlyResult(_): break
        }
    }
    
    func dismissLinkAccount() {}
    func dismissTermsOnly() {}
}

extension RegisterView where ViewModel == MockRegisterVM {
    static var mock: RegisterView {
        return .init(viewModel: MockRegisterVM())
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView.mock
    }
}
#endif

extension RegisterView: LinkAccountNavigator {
    func dismissLinkAccount() {
        viewModel.dismissLinkAccount()
    }
}

extension RegisterView: RegisterTermsOnlyNavigator {
    func dismissRegisterTermsOnly() {
        viewModel.dismissTermsOnly()
    }
}
