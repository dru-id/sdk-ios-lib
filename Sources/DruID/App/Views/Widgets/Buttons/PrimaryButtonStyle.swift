//
//  PrimaryButtonStyle.swift
//  
//
//  Created on 25/5/22.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    enum Size { case small, medium }
    
    @Environment(\.isEnabled) private var isEnabled
    
    let color: Color
    let size: Size
    let isFullWidth: Bool
    
    init(color: Color = Color.partnerPrimary, size: Size = .medium, isFullWidth: Bool = true) {
        self.color = color
        self.size = size
        self.isFullWidth = isFullWidth
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(Color.textOverPrimaryColor)
            .padding(.horizontal, .spacingM)
            .frame(height: size.height)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(configuration.isPressed ? color.darker() : color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(isEnabled ? 1 : 0.3)
    }
}

extension PrimaryButtonStyle.Size {
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 46
        }
    }
    
    var font: Font {
        switch self {
        case .small: return .footnote.bold()
        case .medium: return .subheadline.bold()
        }
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static var primarySmall: PrimaryButtonStyle { PrimaryButtonStyle(size: .small) }
    static func primary(color: Color, size: PrimaryButtonStyle.Size, isFullWidth: Bool = true) -> PrimaryButtonStyle {
        PrimaryButtonStyle(color: color, size: size, isFullWidth: isFullWidth)
    }
}

#if DEBUG
struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            Button("ACEPTAR") { }
            .buttonStyle(.primary)
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")
            
            
            Button("ACEPTAR") { }
            .buttonStyle(.primarySmall)
            .padding()
            .previewLayout(.sizeThatFits)
            .disabled(false)
            .previewDisplayName("Disabled")
        }
    }
}
#endif
