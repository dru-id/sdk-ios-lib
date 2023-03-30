//
//  SecondaryButtonStyle.swift
//  
//
//  Created on 25/5/22.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    let color: Color
    let logoImage: Image
    
    init(color: Color = Color.white, logoImage: Image = Image("apple_logo")) {
        self.color = color
        self.logoImage = logoImage
    }
    
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(Color.partnerSecondary)
            .padding(.horizontal, .spacingM)
            .frame(minHeight: 40)
            .background(configuration.isPressed ? color.darker() : color)
            .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
            .opacity(isEnabled ? 1 : 0.3)
            
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

#if DEBUG
struct SecondaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Aceptar") { }
                .buttonStyle(.secondary)
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")
            
            Button("Aceptar") { }
                .buttonStyle(.secondary)
                .padding()
                .previewLayout(.sizeThatFits)
                .disabled(true)
                .previewDisplayName("Disabled")
        }
        .background(Color.partnerSecondary)
    }
}
#endif
