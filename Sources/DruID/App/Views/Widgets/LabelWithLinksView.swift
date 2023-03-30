import UIKit
import SwiftUI

struct LabelWithLinksView: UIViewRepresentable {
    
    private(set) var attributedString: NSAttributedString
    var linkAction: ((URL) -> Void)
    var textAction: (() -> Void)

    var mutatingWrapper = MutatingWrapper()
    class MutatingWrapper {
        var fontSize: CGFloat = 15
        var textAlignment: NSTextAlignment = .left
        var numberOfLines: Int = 0
        var textColor: UIColor = .black
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> LabelWithLinks {
        let label = LabelWithLinks()
        label.isUserInteractionEnabled = true

        label.numberOfLines = mutatingWrapper.numberOfLines
        label.textFontSize = mutatingWrapper.fontSize
        label.textAlignment = mutatingWrapper.textAlignment
        label.textColor = mutatingWrapper.textColor
        label.lineBreakMode = .byWordWrapping
        
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        label.onLinkPress { url in
            guard let url = url else { return }
            linkAction(url)
        }
        
        label.onTextPress {
            textAction()
        }

        return label
    }

    func updateUIView(_ uiView: LabelWithLinks, context: UIViewRepresentableContext<Self>) {
        uiView.attributedString = attributedString
        uiView.numberOfLines = mutatingWrapper.numberOfLines

        uiView.preferredMaxLayoutWidth = 0.9 * UIScreen.main.bounds.width

        DispatchQueue.main.async {
            uiView.sizeThatFits(
                CGSize(
                    width: uiView.bounds.width,
                    height: CGFloat.greatestFiniteMagnitude
                )
            )
        }
    }
    
    func textFontSize(_ fontSize: CGFloat) -> Self {
        mutatingWrapper.fontSize = fontSize
        return self
    }
    
    func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        mutatingWrapper.textAlignment = textAlignment
        return self
    }
    
    func textColor(_ textColor: UIColor) -> Self {
        mutatingWrapper.textColor = textColor
        return self
    }
    
    func lineLimit(_ number: Int) -> Self {
        mutatingWrapper.numberOfLines = number
        return self
    }
}

