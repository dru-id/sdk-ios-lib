//
//  TertiaryButtonStyle.swift
//  
//
//  Created on 26/5/22.
//

import SwiftUI

struct TertiaryButtonStyle: ButtonStyle {
    
    enum Size { case small, medium }
    
    @Environment(\.isEnabled) private var isEnabled
    
    let color: Color
    let size: Size
    
    init(color: Color = Color.partnerSecondary, size: Size = .medium) {
        self.color = color
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(configuration.isPressed ? color.darker() : color)
            .padding(.horizontal, 16)
            .frame(height: 36)
            .opacity(isEnabled ? 1 : 0.3)
    }
}

extension ButtonStyle where Self == TertiaryButtonStyle {
    static var tertiary: TertiaryButtonStyle { TertiaryButtonStyle() }
    static var tertiarySmall: TertiaryButtonStyle { TertiaryButtonStyle(size: .small) }
    static func tertiary(color: Color, size: TertiaryButtonStyle.Size) -> TertiaryButtonStyle {
        TertiaryButtonStyle(color: color, size: size)
    }
}

#if DEBUG

struct TertiaryButtonStyle_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            Button {
                
            } label: {
                Text("Learn more things")
            }
            .buttonStyle(.tertiary)
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")
            
            
            Button {
                
            } label: {
                Text("Learn more")
            }
            .buttonStyle(.tertiarySmall)
            .padding()
            .previewLayout(.sizeThatFits)
            .disabled(true)
            .previewDisplayName("Disabled")
        }
    }
}
#endif
