//
//  SocialButton.swift
//  
//
//  Created on 23/1/23.
//

import SwiftUI

enum SocialProvider {
    case facebook
    case apple
}

struct SocialButton: View {
    
    private let provider: SocialProvider
    private let action: () -> Void
    
    init(provider: SocialProvider, action: @escaping () -> Void) {
        self.provider = provider
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(provider.logoName, bundle: .module).renderingMode(.template)
                    .foregroundColor(Color.partnerSecondary)
                Text(provider.buttonTitle)
            }
        }
        .buttonStyle(.social)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SocialButton(provider: .facebook) {}
                .padding()
            SocialButton(provider: .apple) {}
                .padding()
        }
    }
}

extension SocialProvider {
    
    var logoName: String {
        switch self {
        case .facebook: return "facebook_logo"
        case .apple: return "apple_logo"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .facebook: return Strings.common_facebook_button
        case .apple: return Strings.common_apple_button
        }
    }
}
