import SwiftUI

enum RegisterConfirmationEvent {
    case onAppear
    case acceptButtonPressed
}

@MainActor
protocol RegisterConfirmationVM: ObservableObject {
    var loading: Bool { get }
    var alert: AlertUIModel? { get set }
    
    var imageData: ImageData? { get }
    var message: String { get }
    var titleVisible: Bool { get }
    
    var entryPointSettings: EntrypointSettingsResponseData? { get }
    
    func handle(event: RegisterConfirmationEvent)
}

struct RegisterConfirmationView<ViewModel: RegisterConfirmationVM>: View {
    
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
        
        VStack {
            VStack {
                if viewModel.entryPointSettings != nil {
                    logoImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                        .padding(.bottom)
                }
                
                Image(systemName: "envelope")
                    .font(.system(size: 67, weight: .thin))
                    .foregroundColor(Color.partnerSecondary)
                
                if viewModel.titleVisible {
                    Text(Strings.register_confirmation_title_text)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                }
                
                Text(viewModel.message)
                    .font(.callout)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, .spacingXXS)
                
                Button(Strings.register_confirmation_accept_button) {
                    viewModel.handle(event: .acceptButtonPressed)
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
        .background(Color.partnerSecondary.ignoresSafeArea())
        .alert(model: $viewModel.alert)
        .loading(loading: viewModel.loading)
        .onAppear {
            viewModel.handle(event: .onAppear)
        }
    }
        
}

#if DEBUG
class MockRegisterConfirmationVM: RegisterConfirmationVM {
    @Published var alert: AlertUIModel? = nil
    let loading: Bool = false
    var imageData: ImageData? = nil
    var message: String = "_Test message"
    var titleVisible: Bool = true
    var entryPointSettings: EntrypointSettingsResponseData? = EntrypointSettingsResponseData.mock()
    
    func handle(event: RegisterConfirmationEvent) { }
}

extension RegisterConfirmationView where ViewModel == MockRegisterConfirmationVM {
    static var mock: RegisterConfirmationView {
        .init(viewModel: MockRegisterConfirmationVM())
    }
}

struct RegisterConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterConfirmationView.mock
    }
}
#endif


