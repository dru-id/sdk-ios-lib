import UIKit
import SwiftUI
import FacebookCore
import SafariServices

public class DruID {
    public static let shared = DruID()
    
    static let sdkNotInitializedError = "You have to initialize the DruID SDK before calling this method with 'configureWithSettings'"
    
    var dependencyManager: DependencyManager?
    
    public var colorModel: ColorModel = ColorModel()
    
    private func areOptionsSet() -> Bool {
        guard let _ = dependencyManager else {
            DruidLogHelper.shared.log(.error, message: "DruID not set up!")
            return false
        }
        return true
    }
    
    // MARK:- SDK public methods
    
    /**
     Initializes the DruID SDK with the given settings
     
     Call it in the AppDelegate of your app.
     
     **application** and **launchOptions** parameters are needed for Facebook SDK initialization
     */
    public func configureWithSettings(
        settings: DruIdSettings,
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        dependencyManager = DependencyManager(settings: settings)
        if let colorModel = settings.colorModel {
            self.colorModel = colorModel
        }
        
        DruidLogHelper.shared.setLogLevel(logLevel: settings.logLevel)
        
        // Facebook SDK
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        DruidLogHelper.shared.log(.debug, message: "DruID set up!")
    }
    
    /**
     Receives as parameter a callback that will inform about te result of the login request.
     
     Returns the login view as an UIViewController.
     
     Your app will be responsible of dismissing it when login finishes.
     */
    @MainActor
    public func loginViewController(loginCallback: @escaping (Result<LoginResponseData, DruidError>) -> Void) -> UIViewController {
        guard areOptionsSet() else { fatalError(DruID.sdkNotInitializedError) }
        let viewModel = LoginViewModel(loginCallback: loginCallback)
        let vc = UIHostingController(rootView: LoginView(viewModel: viewModel))
        return vc
    }
    
    /**
     Receives as parameter a callback that will inform about te result of the login request.
     
     Returns the login view as a SwiftUI view.
     
     Your app will be responsible of dismissing it when login finishes.
     */
    @MainActor
    @ViewBuilder
    public func loginView(loginCallback: @escaping (Result<LoginResponseData, DruidError>) -> Void) -> some SwiftUI.View {
        if !areOptionsSet() {
            Text(DruID.sdkNotInitializedError)
                .foregroundColor(Color.redError)
        }
        let viewModel = LoginViewModel(loginCallback: loginCallback)
        let view = LoginView(viewModel: viewModel)
        view
    }
    
    /**
     Checks whether the user is already logged in or not. It will try to refresh user token if it is no longer valid.
     */
    public func isUserConnected() async -> Result<LoginResponseData, DruidError> {
        let loginResponse = await dependencyManager?.repository.isUserConnected()
        if let loginReponse = loginResponse {
            return Result.success(loginReponse)
        } else {
            return Result.failure(DruidError.userNotLogged)
        }
    }
    
    /**
     Receives as parameter a callback that will inform about te result of the register request.
     
     Returns the register view as an UIViewController.
     
     Your app will be responsible of dismissing it when register finishes.
     */
    @MainActor
    public func registerViewController(
        onCancelButtonPressed: @escaping () -> Void,
        registerCallback:@escaping (Result<RegisterResponseData, DruidError>) -> Void,
        registerAndLoggedInCallback:@escaping (Result<LoginResponseData, DruidError>) -> Void
    ) -> UIViewController {
        guard areOptionsSet() else { fatalError(DruID.sdkNotInitializedError) }
        let viewModel = RegisterViewModel(
            onCancelButtonPressed: onCancelButtonPressed,
            registerCallback: registerCallback,
            registerAndLoggedInCallback: registerAndLoggedInCallback
        )
        let vc = UIHostingController(rootView: RegisterView(viewModel: viewModel))
        return vc
    }
    
    /**
     Receives as parameter a callback that will inform about te result of the register request.
     
     Returns the register view as a SwiftUI view.
     
     Your app will be responsible of dismissing it when register finishes.
     */
    @MainActor
    @ViewBuilder
    public func registerView(
        onCancelButtonPressed: @escaping () -> Void,
        registerCallback:@escaping (Result<RegisterResponseData, DruidError>) -> Void,
        registerAndLoggedInCallback:@escaping (Result<LoginResponseData, DruidError>) -> Void
    ) -> some SwiftUI.View {
        if !areOptionsSet() {
            Text(DruID.sdkNotInitializedError)
                .foregroundColor(Color.redError)
        }
        let viewModel = RegisterViewModel(
            onCancelButtonPressed: onCancelButtonPressed,
            registerCallback: registerCallback,
            registerAndLoggedInCallback: registerAndLoggedInCallback
        )
        let view = RegisterView(viewModel: viewModel)
        view
    }
    
    /**
     Returns the url that allows to edit the user.
     It will check if user is logged in or not, that it's necessary to obtain the url.
     The returned object is a Result<URL, DruidError>
     
     You should use this method along with 'openUrl(url: URL)' to obtain a View or UIViewController to present
     */
    public func getEditUserUrl() async -> Result<URL, DruidError> {
        let isConnectedResult = await isUserConnected()
        switch isConnectedResult {
        case .success(let loginResponse):
            guard let accessToken = loginResponse.content?.sessionInfo?.accessToken?.toBase64(),
                  let urlString = loginResponse.content?.sessionInfo?.links?.editAccount?.replacingOccurrences(of: "{access_token}", with: accessToken),
                  let url = URL(string: urlString)
            else { return .failure(.errorFetchingEditUserUrl) }
            return .success(url)
        case .failure(let error): return .failure(error)
        }
    }
    
    /**
     Returns a SwiftUI view to edit the user which contains a SFSafariViewController with the given url
     */
    @MainActor
    @ViewBuilder
    public func openUrl(url: URL) -> some SwiftUI.View {
        SafariView(url: url)
    }
    
    /**
     Returns a SFSafariViewController with the given url
     */
    public func openUrl(url: URL) -> UIViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredBarTintColor = UIColor(Color.partnerSecondary)
        vc.preferredControlTintColor = .white
        return vc
    }
}

