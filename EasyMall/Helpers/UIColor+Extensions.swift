import UIKit

extension UIColor {
    
    /// Stores default shimmer CGColor array
    static var defaultShimmerColors: [CGColor] {
        [
            systemGray5.cgColor(multipliedBy: 0.95),
            systemGray5.cgColor(multipliedBy: 1.1),
            systemGray5.cgColor(multipliedBy: 0.95)
        ]
    }
    
    /// Stores default shimmer border CGColor array
    static var defaultShimmerBorderColors: [CGColor] {
        [
            systemGray5.cgColor,
            systemGray5.cgColor(multipliedBy: 1.8),
            systemGray5.cgColor
        ]
    }
    
    /// Returns a CGColor with each of its components (except alpha) multiplied by the specified multiplier.
    func cgColor(multipliedBy multiplier: CGFloat) -> CGColor {
        
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red *= multiplier
        green *= multiplier
        blue *= multiplier
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }
}
