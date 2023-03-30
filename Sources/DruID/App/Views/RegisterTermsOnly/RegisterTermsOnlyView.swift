import SwiftUI

enum RegisterTermsOnlyEvent {
    case onAppear
    case sendButtonPressed
    case cancelButtonPressed
}

@MainActor
protocol RegisterTermsOnlyVM: ObservableObject {
    var loading: Bool { get }
    var alert: AlertUIModel? { get set }
    var imageData: ImageData? { get }

    var entryPointSettings: EntrypointSettingsResponseData? { get }
    var dynamicFormViewModel: DynamicFormViewModel? { get }
    
    func handle(event: RegisterTermsOnlyEvent)
}

struct RegisterTermsOnlyView<ViewModel: RegisterTermsOnlyVM>: View {
    
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
                VStack {
                    VStack {
                        if viewModel.entryPointSettings != nil {
                            logoImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 170)
                                .padding(.bottom)
                        }
                        
                        if let dynamicFormViewModel = viewModel.dynamicFormViewModel {
                            DynamicFormView(viewModel: dynamicFormViewModel)
                        }
                        
                        Button(Strings.register_terms_only_send_button) {
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
class MockRegisterTermsOnlyVM: RegisterTermsOnlyVM {
    @Published var alert: AlertUIModel? = nil
    let loading: Bool = false
    
    var imageData: ImageData?
    var entryPointSettings: EntrypointSettingsResponseData? = EntrypointSettingsResponseData.mock()
    var dynamicFormViewModel: DynamicFormViewModel?
    
    func handle(event: RegisterTermsOnlyEvent) { }
    
    init() {
        if let imageBase64String = entryPointSettings?.content.image?.data,
           let data = Data(base64Encoded: imageBase64String) {
            imageData = ImageData(data: data)
        }
        dynamicFormViewModel = .init(
            items: nil,
            assertions: entryPointSettings?.content.assertions.items,
            sendCallback: {
                // Does nothing
            })
    }
}

extension RegisterTermsOnlyView where ViewModel == MockRegisterTermsOnlyVM {
    static var mock: RegisterTermsOnlyView {
        .init(viewModel: MockRegisterTermsOnlyVM())
    }
}

struct RegisterTermsOnlyView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterTermsOnlyView.mock
    }
}
#endif




