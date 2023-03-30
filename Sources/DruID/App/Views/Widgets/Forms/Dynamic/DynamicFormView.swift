import SwiftUI

enum DynamicFormEvent {
    case onAppear
    case sendButtonPressed
}

@MainActor
protocol DynamicFormVM: ObservableObject {
    var loading: Bool { get }
    var alert: AlertUIModel? { get set }
    
    var items: [FormItemModel] { get set }
    var shouldShowAcceptAll: Bool { get }
    var acceptAllisOn: Bool { get set }
    
    func handle(event: DynamicFormEvent)
}

struct DynamicFormView<ViewModel: DynamicFormVM>: View {
    
    @StateObject var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        
        VStack {
            ForEach(viewModel.items) { item in
                if viewModel.shouldShowAcceptAll && item.isFirstAssertion {
                    AcceptAllView(isOn: $viewModel.acceptAllisOn)
                        .padding(.top)
                }
                DynamicInputView(model: item)
            }
        }
        
    }
}

#if DEBUG
class MockDynamicFormVM: DynamicFormVM {

    @Published var alert: AlertUIModel? = nil
    let loading: Bool = false
    
    var items: [FormItemModel] = EntrypointSettingsResponseData.mock().content.fields.items.map {
        FormItemModel(
            fieldItem: $0,
            isLastInput: false,
            onSubmit: {}
        )
    }
    var shouldShowAcceptAll: Bool = true
    var acceptAllisOn: Bool = false

    func handle(event: DynamicFormEvent) { }
}

extension DynamicFormView where ViewModel == MockDynamicFormVM {
    static var mock: DynamicFormView {
        .init(viewModel: MockDynamicFormVM())
    }
}

struct DynamicFormView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicFormView.mock
    }
}
#endif



