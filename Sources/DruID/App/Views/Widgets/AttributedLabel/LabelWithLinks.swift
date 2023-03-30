import UIKit

protocol LabelWithLinksDelegate: AnyObject {
    func labelLinkDidPress(url: URL?)
}

class LabelWithLinks: UILabel {
    weak var delegate: LabelWithLinksDelegate?
    private var tapGesture = UITapGestureRecognizer()
    private var links: [LabelLink] = []

    var textFontSize: CGFloat = 13
    var linkAction: ((URL?) -> Void)?
    var textAction: (() -> Void)?

    var attributedString: NSAttributedString? {
        didSet {
            guard let attributedString = attributedString else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                var universalLabelLinks: [AttributedTextWithLink] = []
                
                attributedString.enumerateAttributes(in: attributedString.range) { (attributes, range, _) in
                    let attributedTextWithLink = self.prepareAttributedTextWithLinks(
                        attributedString,
                        attributes: attributes,
                        range: range
                    )
                    universalLabelLinks.append(attributedTextWithLink)
                }
                
                self.concat(textsWithLinks: universalLabelLinks)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCommon()
    }

    func onLinkPress(action: @escaping (URL?) -> Void) {
        self.linkAction = action
    }
    
    func onTextPress(action: @escaping () -> Void) {
        self.textAction = action
    }
}

// MARK: - Add Link

extension LabelWithLinks {
    private func addLink(_ universalLabelLink: LabelLink) {
        guard let attributedString = self.attributedText else { return }
        let attributedText = NSMutableAttributedString(attributedString: attributedString)
        attributedText.addAttributes(
            universalLabelLink.linkAttributes.attributes,
            range: universalLabelLink.textCheckingResult.range
        )
        self.attributedText = attributedText
        links.append(universalLabelLink)
    }
    
    private func concat(textsWithLinks: [AttributedTextWithLink]) {
        let attributedText = NSMutableAttributedString(string: "")
        var labelLinks = [LabelLink]()

        textsWithLinks.forEach { item in
            attributedText.append(NSAttributedString(
                string: item.text,
                attributes: item.attributes)
            )
            
            if let link = item.link,
               let url = URL(string: link),
               let linkAttributes = item.linkAttributes {

                let range = (attributedText.string as NSString).range(of: item.text)
                let labelLink = LabelLink(
                    linkAttributes: linkAttributes,
                    textCheckingResult: .linkCheckingResult(range: range, url: url)
                )
                labelLinks.append(labelLink)
            }
        }

        self.attributedText = attributedText
        labelLinks.forEach { addLink($0) }
    }
}

// MARK: - Prepare Text

extension LabelWithLinks {
    
    private func prepareTextAttributes(_ attributes: [NSAttributedString.Key : Any]) -> [NSAttributedString.Key: Any] {
        guard let font: UIFont = attributes[NSAttributedString.Key.font] as? UIFont else {
            return attributes
        }

        let defaultFont: UIFont

        if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
            defaultFont = UIFont.italicSystemFont(ofSize: self.textFontSize)
        } else {
            defaultFont = UIFont.systemFont(ofSize: self.textFontSize, weight: font.weight)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        
        var updatedAttributes = attributes
        updatedAttributes[.font] = defaultFont
        updatedAttributes[.paragraphStyle] = paragraphStyle
        
        return updatedAttributes
    }
    
    private func prepareAttributedTextWithLinks(
        _ attributedString: NSAttributedString,
        attributes: [NSAttributedString.Key : Any],
        range: NSRange
    ) -> AttributedTextWithLink {
        let string = attributedString.attributedSubstring(from: range).string

        let textAttributes = self.prepareTextAttributes(attributes)

        if let link = attributes[.link] as? String, let url = URL(string: link) {
            return AttributedTextWithLink(
                text: string,
                attributes: [:],
                link: url.absoluteString,
                linkAttributes: LinkAttributes(attributes: textAttributes)
            )
        } else {
            var defaultTextAttributes = textAttributes
            defaultTextAttributes[.foregroundColor] = self.textColor

            return AttributedTextWithLink(
                text: string,
                attributes: defaultTextAttributes
            )
        }
    }
}

// MARK: - Setup

private extension LabelWithLinks {
    private func setupCommon() {
        isUserInteractionEnabled = true
        setupTapGestureRecognizer()
    }

    private func setupTapGestureRecognizer() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onLabelTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
}

// MARK: - Get a link on tap

private extension LabelWithLinks {
    @objc func onLabelTap(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        guard let link = getLinkAtPoint(touchPoint) else {
            textAction?()
            return
        }
        let url = link.textCheckingResult.url
        delegate?.labelLinkDidPress(url: url)
        linkAction?(url)
    }

    private func getLinkAtPoint(_ point: CGPoint) -> LabelLink? {
        let index = indexOfAttributedTextCharacterAtPoint(point)
        return links.first { NSLocationInRange(index, $0.textCheckingResult.range) == true }
    }

    private func containLinkAtPoint(_ point: CGPoint) -> Bool {
        let index = indexOfAttributedTextCharacterAtPoint(point)
        return links.contains { NSLocationInRange(index, $0.textCheckingResult.range) }
    }

    private func indexOfAttributedTextCharacterAtPoint(_ point: CGPoint) -> Int {
        guard let attributedString = self.attributedText else { return -1 }

        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LabelWithLinks: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        containLinkAtPoint(touch.location(in: self)) // Commented to allow tapping on text to toggle, not just on link
        true
    }
}

// MARK: - NSAttributedString

extension NSAttributedString {
    var range: NSRange {
        NSRange(location: 0, length: length)
    }
}
