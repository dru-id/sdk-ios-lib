import SwiftUI

@MainActor
class RegisterConfirmationViewModel: RegisterConfirmationVM {
    
    @Published private (set) var loading: Bool = false
    @Published var alert: AlertUIModel? = nil
    
    @Published var imageData: ImageData? = nil
    @Published var message: String
    @Published var titleVisible: Bool = true

    private (set) var entryPointSettings: EntrypointSettingsResponseData? = nil
    private var onAcceptButtonPressed: () -> Void
        
    init(
        entryPointSettings: EntrypointSettingsResponseData? = nil,
        message: String,
        onAcceptButtonPressed: @escaping () -> Void
    ) {
        self.entryPointSettings = entryPointSettings
        if let imageBase64String = entryPointSettings?.content.image?.data,
           let data = Data(base64Encoded: imageBase64String) {
            self.imageData = ImageData(data: data)
        }
        self.message = message
        self.onAcceptButtonPressed = onAcceptButtonPressed
        if message == Strings.register_confirmation_sucess_already_confirmed_text {
            titleVisible = false
        }
    }

    func handle(event: RegisterConfirmationEvent) {
        switch event {
        case .onAppear: break
        case .acceptButtonPressed:
            onAcceptButtonPressed()
        }
    }
}
