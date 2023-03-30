import UIKit

struct AttributedTextWithLink {
    var text: String
    var attributes: [NSAttributedString.Key: Any]
    var link: String?
    var linkAttributes: LinkAttributes?
}

struct LinkAttributes {
    var attributes: [NSAttributedString.Key: Any]
}

struct LabelLink {
    var linkAttributes: LinkAttributes
    var textCheckingResult: NSTextCheckingResult
}

extension UIFont {
    var weight: UIFont.Weight {
        guard let weightNumber = traits[.weight] as? NSNumber else { return .regular }
        let weightRawValue = CGFloat(weightNumber.doubleValue)
        let weight = UIFont.Weight(rawValue: weightRawValue)
        return weight
    }

    private var traits: [UIFontDescriptor.TraitKey: Any] {
        fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any] ?? [:]
    }
}
