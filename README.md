# DruID

This is an SDK designed to integrate with [DruID API](https://dru-id.com/developers/apis/)

DruiID is an Identity Management platform designed for marketers to consolidate all consumer data, activities, social information and UX at any digital touchpoint integrated.

With this SDK you can make use of Druid's API in a simple way in your project. This SDK allows you to obtain login and register views ready to use in your app, as well as methods to check if the user is connected or to edit the user's profile.

## Installation

### Swift Package Manager

There two ways of installing DruID using [Swift Package Manager](https://swift.org/package-manager/):

#### Installing from Xcode

Add a package by selecting `File` → `Add Packages…` in Xcode’s menu bar.

Search for the DruID SDK using the repo's URL:
```console
https://github.com/dru-id/sdk-ios-lib.git
```
Next, set the **Dependency Rule** to be `Up to Next Major Version`.

Then, select **Add Package**.

#### Alternatively, add DruID to a `Package.swift` manifest

To integrate via a `Package.swift` manifest instead of Xcode, you can add
DruID to the dependencies array of your package:

```swift
dependencies: [
  .package(
    name: "DruID",
    url: "https://github.com/dru-id/sdk-ios-lib.git",
    .upToNextMajor(from: "1.0.3")
  ),

  // Any other dependencies you have...
],
```

Then, in any target that depends on DruID, add it to the `dependencies`
array of that target:

```swift
.target(
  name: "MyTargetName",
  dependencies: [
    .product(name: "DruID", package: "DruID"),
  ]
),
```

### Requirements
    
- iOS >= 14
- Swift v5

### Usage

#### Initialization

First of all, in your AppDelegate initialize the SDK with your settings:

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        DruID.shared.configureWithSettings(
            settings: .init(
                authBaseURL: "...",
                graphBaseURL: "...",
                clientId: "...",
                clientSecret: "...",
                entryPointId: "..",
                colorModel: ColorModel(),
                logLevel: .debug
            ),
            application: application,
            launchOptions: launchOptions
        )
        
        return true
    }
}
```

- authBaseURL: the host url for the Authorization API, for example "https://auth.demo.dru-id.com"
- graphBaseURL: the host url for the Registration API, for example "https://graph.demo.dru-id.com"
- clientId: client Id for your DruID app.
- clientSecret: client secret for your DruID app.
- entryPointId: id of the entry point
- colorModel: (optional) using model `ColorModel` you could configure the 'primary', 'secondary' and 'textOverPrimaryColor' colors of the DruID SDK's screens to suit your app's design.
- logLevel: (optional) determines how much information you will see in the log (debug, info, error).

#### Login

To show the login view you can obtain it as a SwiftUI view:

```swift
DruID.shared.loginView(loginCallback: loginCallback)
```

or as a ViewController:

```swift
DruID.shared.loginViewController(loginCallback: loginCallback)
```

In both methods you will need to provide a callback that will return the result of the login operation. If sucessful, it will return the user information. Your app will be responsible of dismissing the view when login finishes.

For example, in SwiftUI you could show the login view like this:

```swift
.sheet(isPresented: $viewModel.showingLogin) {
    NavigationView {
        DruID.shared.loginView(loginCallback: { result in
            viewModel.handle(event: .onLoginResult(result))
        })
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    viewModel.handle(event: .dismissLogin)
                }
                .foregroundColor(.white)
            }
        }
    }
}
```

In `onLoginResult` you could dismiss the sheet and handle the result:

```swift
func onLoginResult(_ result: Result<LoginResponseData, DruidError>) {
    showingLogin = false
    
    switch result {
    case .success(let response): // parse reponse with user info...
    case .failure(let error): // check error...
    }
}
```

##### Apple login

If your client id allows it, you will see a 'Sign with Apple' button on the login and register views. This will allow customers sign in with their Apple ID.

To support this type of login you will need to complete the first steps of the [Apple implementation documentation](https://developer.apple.com/documentation/authenticationservices/implementing_user_authentication_with_sign_in_with_apple) to enable the "Sign in with Apple" capability.

If other third party login buttons are showed, Apple may enforce your app to offer the "Sign with Apple" button. Check [App Store review guidelines](https://developer.apple.com/app-store/review/guidelines/)

##### Facebook login

Similarly to Apple login, if your client id allows it, you will see a 'Login with Facebook' button on the login and register views.

To support this type of login you will need to complete the steps 3 and 4 of the [Login with Facebook SDK documentation](https://developers.facebook.com/docs/facebook-login/ios/)

If your app does not integrate the login with Facebook and you don't set up your project for it, you could see some warnings in the log, but as long as you don't configure DruID to show the Facebook login button, you will be safe.

#### Check if user is connected

You can use the following async method:

```swift
DruID.shared.isUserConnected()
```

It will respond with a `Result<LoginResponseData, DruidError>` like login. If sucessful, it will return updated user information.

For example, you could use it like this:

```swift
private func isUserConnected() {
    loading = true // show something that indicates the user that this is an async task
    Task { [weak self] in
        let result = await DruID.shared.isUserConnected()
        self?.loading = false
        switch result {
        case .success(let response):
            if let errorMessage = response.result.errors?.first?.details {
                // show error message
            } else {
                // user is connected, parse response
            }
        case .failure(let error):
            // show/check error
        }
    }
}
```

#### Register

To show the register view you can obtain it as a SwiftUI view:

```swift
DruID.shared.registerView(
    onCancelButtonPressed: {
        // Dismiss view
    },
    registerCallback: { result in
        // Handle result
    },
    registerAndLoggedInCallback: { result in
        // Handle result
    }
)
```

or as a ViewController:

```swift
DruID.shared.registerViewController(
    onCancelButtonPressed: {
        // Dismiss view
    },
    registerCallback: { result in
        // Handle result
    },
    registerAndLoggedInCallback: { result in
        // Handle result
    }
)
```

In both methods you will need to provide a callback that will return the result of the register operation. Your app will be responsible of dismissing the view when register finishes.

For example, in SwiftUI you could show the register view like this:

```swift
.sheet(isPresented: $viewModel.showingRegister) {
    DruID.shared.registerView(
        onCancelButtonPressed: {
            viewModel.handle(event: .dismissRegister)
        },
        registerCallback: { result in
            viewModel.handle(event: .onRegisterResult(result))
        },
        registerAndLoggedInCallback: { result in
            viewModel.handle(event: .onRegisterAndLoginResult(result))
        }
    )
}
```

In `onRegisterResult` you could dismiss the sheet and handle the result:

```swift
private func onRegisterResult(_ result: Result<RegisterResponseData, DruidError>) {
    showingRegister = false
    
    switch result {
    case .success(let response): // parse reponse...
    case .failure(let error): // check error...
    }
}
```

In `onRegisterAndLoginResult` you could do similarly, but taking into account that user is both registered and logged in at this point.

#### Edit user

The user profile can be edited on a web view with a provided url.

To fetch the url you use the following async method:

```swift
DruID.shared.getEditUserUrl()
```

that could be used, for example, like this:

```swift
Task { [weak self] in
    let result = await DruID.shared.getEditUserUrl()
    switch result {
    case .success(let url):
        // Show url
    case .failure(let error):
        // Show error
    }
}
```

It will respond with a `Result<URL, DruidError>`. If sucessful, it will return the url. It will check if user is logged in or not, that it's necessary to obtain the url.

You can open this url with in [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) using the following  DruID functions.

To obtain it as a SwiftUI view:

```swift
DruID.shared.openUrl(url: url)
```

or as a ViewController:

```swift
DruID.shared.openUrl(url: url)
```

For example, you could use it like this:

```swift
.sheet(isPresented: $viewModel.showingEditUser) {
    if let url = viewModel.editUserUrl {
        DruID.shared.openUrl(url: url)
    }
}
```

Where `editUserUrl` would be a `var editUserUrl: URL?` previously set on you view model after calling `DruID.shared.getEditUserUrl()`.
