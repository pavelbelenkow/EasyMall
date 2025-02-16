import UIKit

final class CustomLabel: UILabel {
    
    // MARK: - Private Properties
    
    private var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    // MARK: - Override Properties
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
    
    // MARK: - Override Methods
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    // MARK: - Configure Label
    
    func configure(
        textColor: UIColor = .white,
        font: UIFont = .systemFont(ofSize: 17),
        alignment: NSTextAlignment = .left,
        numberOfLines: Int = .zero,
        backgroundColor: UIColor = .clear,
        cornerRadius: CGFloat = .zero,
        textInsets: UIEdgeInsets = .zero,
        adjustsFontSizeToFitWidth: Bool = false
    ) {
        self.textColor = textColor
        self.font = font
        self.textAlignment = alignment
        self.numberOfLines = numberOfLines
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.textInsets = textInsets
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.clipsToBounds = true
    }
}
