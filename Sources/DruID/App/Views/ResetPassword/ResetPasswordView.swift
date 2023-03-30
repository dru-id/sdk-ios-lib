import SwiftUI

enum ResetPasswordEvent {
    case onAppear
    case sendButtonPressed
    case cancelButtonPressed
}

@MainActor
protocol ResetPasswordVM: ObservableObject {
    var loading: Bool { get }
    var alert: AlertUIModel? { get set }
    
    var imageData: ImageData? { get }
    var username: String { get set }
    var usernameError: String { get }
    
    var entryPointSettings: EntrypointSettingsResponseData? { get }
    
    func handle(event: ResetPasswordEvent)
}

struct ResetPasswordView<ViewModel: ResetPasswordVM>: View {
    
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
    
    var body: some View {
        
        NavigationView {
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
                        
                        Text(Strings.reset_password_header_text)
                            .font(.callout)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        TextFieldView(
                            title: Strings.reset_password_email_title,
                            placeholder: Strings.reset_password_email_placeholder,
                            error: viewModel.usernameError,
                            text: $viewModel.username
                        )
                        .backport.configureTextField(
                            submitCondition: true,
                            keyboard: .emailAddress,
                            contentType: .emailAddress,
                            submitLabel: .continue
                        ) {
                            viewModel.handle(event: .sendButtonPressed)
                        }
                        .backport.textInputAutocapitalization(.never)
                        .padding(.top)
                        
                        Button(Strings.reset_password_send_button) {
                            viewModel.handle(event: .sendButtonPressed)
                        }
                        .buttonStyle(.primary)
                        .padding(.top)
                    }
                    .padding(.all, .spacingM)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.shadow, radius: 21)
                }
                .padding([.leading, .trailing], .spacingM)
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
    }
        
}

#if DEBUG
class MockResetPasswordVM: ResetPasswordVM {
    @Published var alert: AlertUIModel? = nil
    let loading: Bool = false
    var imageData: ImageData? = nil
    var username: String = ""
    var usernameError: String = ""
    var entryPointSettings: EntrypointSettingsResponseData? = EntrypointSettingsResponseData.mock()
    
    func handle(event: ResetPasswordEvent) {}
}

extension ResetPasswordView where ViewModel == MockResetPasswordVM {
    static var mock: ResetPasswordView {
        .init(viewModel: MockResetPasswordVM())
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView.mock
    }
}
#endif

