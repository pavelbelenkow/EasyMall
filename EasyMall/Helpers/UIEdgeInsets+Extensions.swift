import UIKit

extension UIEdgeInsets {
    
    /// Stores edge insets that equal `8.0`
    static let small: Self = makeInsets(for: Const.spacingSmall)
    
    /// Stores edge insets that equal `16.0`
    static let medium: Self = makeInsets(for: Const.spacingMedium)
    
    /// Returns insets by specified value
    static func makeInsets(for value: CGFloat) -> Self {
        .init(top: value, left: value, bottom: value, right: value)
    }
}
