//
//  AcceptAllView.swift
//  
//
//  Created on 20/2/23.
//

import SwiftUI

struct AcceptAllView: View {
    @Binding var isOn: Bool
    
    private var onColor: Color

    init(
        isOn: Binding<Bool>,
        onColor: Color = .partnerPrimary
    ) {
        self._isOn = isOn
        self.onColor = onColor
    }
    
    var body: some View {
        HStack {
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .partnerPrimary))
                .labelsHidden()
            Text(Strings.common_accept_all_switch)
                .padding(.leading, .spacingXS)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AcceptAllView_Previews: PreviewProvider {
    
    struct AcceptAllViewHolder: View {
        @State var isOn = false

        var body: some View {
            VStack {
                AcceptAllView(isOn: $isOn)
            }
        }
    }
    
    static var previews: some View {
        AcceptAllViewHolder()
    }
}
