//
//  SocialButtonStyle.swift
//
//
//  Created on 25/5/22.
//

import SwiftUI

struct SocialButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    let color = Color.white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(Color.partnerSecondary)
            .padding(.horizontal, .spacingM)
            .frame(minHeight: 46)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? color.darker() : color)
            .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12.5, style: .continuous)
                    .stroke(Color.partnerSecondary, lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : 0.3)
        
    }
}

extension ButtonStyle where Self == SocialButtonStyle {
    static var social: SocialButtonStyle { SocialButtonStyle() }
}

#if DEBUG
struct SocialButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Aceptar") { }
                .buttonStyle(.social)
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")
            
            Button("Aceptar") { }
                .buttonStyle(.social)
                .padding()
                .previewLayout(.sizeThatFits)
                .disabled(true)
                .previewDisplayName("Disabled")
        }
    }
}
#endif
