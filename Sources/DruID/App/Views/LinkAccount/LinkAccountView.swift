import SwiftUI

public enum LinkAccountEvent {
    case onAppear
    case syncButtonPressed
    case cancelButtonPressed
}

@MainActor
public protocol LinkAccountVM: ObservableObject {
    var loading: Bool { get }
    var alert: AlertUIModel? { get set }
    
    var password: String { get set }    
    var passwordError: String { get }
    
    func handle(event: LinkAccountEvent)
}

public struct LinkAccountView<ViewModel: LinkAccountVM>: View {
        
    private enum FieldFocus { case password }

    @StateObject var viewModel: ViewModel
    @State private var focus: FieldFocus?

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        Image("druid_logo", bundle: .module)
                            .padding(.bottom)
                        
                        Text(Strings.link_account_header_text)
                            .font(.callout)
                        
                        SecureFieldView(
                            title: Strings.link_account_password_title,
                            placeholder: Strings.link_account_password_placeholder,
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
                            viewModel.handle(event: .syncButtonPressed)
                        }
                        
                        Button(Strings.link_account_sync_button) {
                            viewModel.handle(event: .syncButtonPressed)
                        }
                        .buttonStyle(.primary)
                        .padding(.top)
                    }
                    .padding(EdgeInsets(top: .spacingM, leading: .spacingM, bottom: .spacingM, trailing: .spacingM))
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.shadow, radius: 21)
                }
                .padding(.init(top: 64, leading: .spacingM, bottom: .spacingXL, trailing: .spacingM))
            }
            .background(Color.partnerSecondary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Strings.common_cancel_text) {
                        viewModel.handle(event: .cancelButtonPressed)
                    }.foregroundColor(.white)
                }
            }
        }
        .alert(model: $viewModel.alert)
        .loading(loading: viewModel.loading)
        .onAppear {
            viewModel.handle(event: .onAppear)
        }
    }
}

#if DEBUG
class MockLinkAccountVM: LinkAccountVM {
    
    @Published var alert: AlertUIModel? = nil
    let loading: Bool = false
    
    var password: String = ""
    var passwordError: String = ""
    
    func handle(event: LinkAccountEvent) { }
}

extension LinkAccountView where ViewModel == MockLinkAccountVM {
    static var mock: LinkAccountView {
        .init(viewModel: MockLinkAccountVM())
    }
}

struct LinkAccountView_Previews: PreviewProvider {
    static var previews: some View {
        LinkAccountView.mock
    }
}
#endif
