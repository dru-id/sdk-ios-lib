//
//  AssertionView.swift
//
//
//  Created on 10/2/23.
//

import SwiftUI

struct AssertionView: View {
    
    @Binding var checked: Bool
    @State var showSafari = false
    @State var urlToOpen: URL? = nil
    @State var additionalInfoExpanded: Bool = false
    
    private let onColor: Color
    private let attributedString: NSAttributedString
    private let additionalInfo: String?
    private let error: String
    
    init(
        checked: Binding<Bool>,
        onColor: Color = Color.partnerPrimary,
        linkColor: Color = .black.opacity(0.6),
        text: String,
        links: [LinkData],
        additionalInfo: String? = nil,
        error: String = ""
    ) {
        self._checked = checked
        self.onColor = onColor
        self.attributedString = AssertionView.replaceTextLinks(rawText: text, links: links, linkColor: linkColor)
        self.additionalInfo = additionalInfo
        self.error = error
    }
    
    var additionalInfoImageName: String {
        if additionalInfoExpanded == false {
            return "plus.circle"
        } else {
            return "minus.circle"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: checked ? "checkmark.square.fill" : "square")
                    .foregroundColor(checked ? onColor : Color.gray)
                    .onTapGesture {
                        self.checked.toggle()
                    }
                
                Spacer()
                    .frame(width: .spacingM)
                
                HStack(alignment: .bottom) {
                    LabelWithLinksView(
                        attributedString: attributedString,
                        linkAction: { url in
                            self.urlToOpen = url
                            self.showSafari = true
                        },
                        textAction: {
                            self.checked.toggle()
                        }
                    )
                    
                    if additionalInfo?.isEmpty == false {
                        Image(systemName: additionalInfoImageName)
                            .foregroundColor(Color.gray)
                            .onTapGesture {
                                self.additionalInfoExpanded.toggle()
                            }
                            .padding(.leading, .spacingXS)
                            .alignmentGuide(.bottom) { dimensions in
                                dimensions[.bottom]
                            }
                    }
                }
            }
            
            if let additionalInfo = additionalInfo, additionalInfoExpanded {
                Text(additionalInfo)
                    .padding(.init(top: .spacingM, leading: 50, bottom: 0, trailing: .spacingXXL))
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
            }
            
            Spacer()
                .frame(height: error.isEmpty ? 0 : 10)
            Text(error)
                .foregroundColor(.redError)
                .font(.footnote.weight(.semibold))
                .opacity(error.isEmpty ? 0 : 1)
                .frame(height: error.isEmpty ? 0 : nil)
        }
        .sheet(isPresented: $showSafari) {
            if let urlToOpen = urlToOpen {
                SafariView(url: urlToOpen)
            }
        }
    }
}

extension AssertionView {
    
    struct LinkData {
        let text: String
        let url: String
    }
    
    static func replaceTextLinks(rawText: String, links: [LinkData], linkColor: Color) -> NSAttributedString {
        let pattern = #"%(\d*)\$s"#
        var replacedText = rawText
        
        var index = 0
        while let range = replacedText.range(of: pattern, options: .regularExpression) {
            let placeholder = replacedText[range]
            if index < links.count {
                let linkData = links[index]
                replacedText = replacedText.replacingOccurrences(of: placeholder, with: linkData.text)
            }
            index += 1
        }
        
        let attributedString = NSMutableAttributedString(string: replacedText)
        let fullRange = (attributedString.string as NSString).range(of: replacedText)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: fullRange)
        
        links.forEach { link in
            let range = (attributedString.string as NSString).range(of: link.text)
            attributedString.addAttributes(
                [
                    .link : link.url,
                    .foregroundColor: UIColor(linkColor),
//                    .underlineColor: UIColor(linkColor),
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ],
                range: range
            )
        }
        
        return attributedString
    }
    
}

struct AssertionView_Previews: PreviewProvider {
    
    struct AssertionViewHolder: View {
        @State var checked = false
        
        var body: some View {
            VStack {
                AssertionView(
                    checked: $checked,
                    text: "I have read and accept the terms and conditions of this product",
                    links: [],
                    error: ""
                )
                .padding(.top)
                
                AssertionView(
                    checked: $checked,
                    onColor: Color.partnerPrimary,
                    linkColor: .black.opacity(0.6),
                    text: "I have read and accept the %1$s and the %2$s",
                    links: [
                        .init(text: "terms and conditions", url: "https://statics.ciam.demo.dru-id.com/viewer/legalterms/general_conditions/terms/es"),
                        .init(text: "política de privacidad", url: "https://statics.ciam.demo.dru-id.com/viewer/legalterms/privacy_policy/privacidad/es")
                    ],
                    additionalInfo: "I accept that DRUID, may process and use the personal data that I have provided for the purpose of receiving information about products and services, offers, promotions, invitations to events and third party news. The data will be used indefinitely until the contrary is communicated. DRUID will not transfer my data to third parties. The legal basis for the treatment of this data is the legitimation by consent of the User.",
                    error: ""
                )
                .padding(.top)
                
                AssertionView(
                    checked: $checked,
                    onColor: Color.partnerPrimary,
                    linkColor: .black.opacity(0.6),
                    text: "Subscribe to our newsletter",
                    links: [],
                    error: "Mandatory"
                )
                .padding(.top)
            }
        }
    }
    
    static var previews: some View {
        AssertionViewHolder()
    }
}



