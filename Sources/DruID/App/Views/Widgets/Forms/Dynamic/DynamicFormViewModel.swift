import SwiftUI

@MainActor
class DynamicFormViewModel: DynamicFormVM {
    
    @Published private (set) var loading: Bool = false
    @Published var alert: AlertUIModel? = nil
    
    @Published var items: [FormItemModel] = []
    @Published var shouldShowAcceptAll: Bool = false
    @Published var acceptAllisOn: Bool = false {
        didSet {
            toggleAssertions(enabled: acceptAllisOn)
        }
    }

    private let sendCallback:() -> Void
    private var forcingAccepAllValue: Bool = false

    init(
        items: [EntrypointSettingsResponseData.FieldItemData]? = nil,
        assertions: [EntrypointSettingsResponseData.AssertionItemData]? = nil,
        sendCallback: @escaping () -> Void
    ) {
        self.sendCallback = sendCallback
        if let items = items {
            self.items = items.map {
                FormItemModel(
                    fieldItem: $0,
                    isLastInput: $0.id == items.last?.id,
                    onSubmit: { [weak self] in self?.handle(event: .sendButtonPressed) }
                )
            }
        }
        if let assertions = assertions {
            if assertions.count > 1 {
                shouldShowAcceptAll = true
            }
            self.items += assertions.enumerated().map { index, item in
                FormItemModel(
                    assertion: item,
                    isFirstAssertion: index == 0,
                    onAssertionToggle: { [weak self] in
                        self?.checkAssertionsStatus()
                    },
                    onSubmit: {
                        // Does nothing
                    }
                )
            }
        }
    }

    func handle(event: DynamicFormEvent) {
        switch event {
        case .onAppear: break
        case .sendButtonPressed:
            guard isValid() else { return }
            sendCallback()
        }
    }
    
    func isValid() -> Bool {
        var valid = true
    
        for model in items {
            if !model.validate() {
                valid = false
            }
        }
        return valid
    }
    
    private func toggleAssertions(enabled: Bool) {
        if !forcingAccepAllValue {
            for model in items {
                if model.assertion != nil {
                    model.assertionValue = enabled
                }
            }
        }
    }
    
    private func checkAssertionsStatus() {
        let enabledItems = items.reduce(0, {
            let assertionEnabled = $1.assertion != nil && $1.assertionValue
            return $0 + (assertionEnabled ? 1 : 0)
        })
        
        forcingAccepAllValue = true
        if enabledItems == items.filter({ $0.assertion != nil }).count {
            acceptAllisOn = true
        } else {
            acceptAllisOn = false
        }
        forcingAccepAllValue = false
    }
}
