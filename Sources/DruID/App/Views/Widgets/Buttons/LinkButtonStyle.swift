//
//  LinkButtonStyle.swift
//  
//
//  Created on 26/5/22.
//

import SwiftUI

struct LinkButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    let color = Color.partnerPrimary

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.subheadline)
            .foregroundColor(Color.grayText)
            .padding(.horizontal, 16)
            .frame(height: 46)
            .opacity(isEnabled ? 1 : 0.3)
    }
}

extension ButtonStyle where Self == LinkButtonStyle {
    static var linkButton: LinkButtonStyle { LinkButtonStyle() }
}

#if DEBUG

struct LinkButtonStyle_Previews: PreviewProvider {
    
    static var previews: some View {
        Button {
            
        } label: {
            Text("Learn more").underline()
        }
        .buttonStyle(.linkButton)
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Enabled")
        
        
        Button {
            
        } label: {
            Text("Learn more").underline()
        }
        .buttonStyle(.linkButton)
        .padding()
        .previewLayout(.sizeThatFits)
        .disabled(true)
        .previewDisplayName("Disabled")
    }
}
#endif
