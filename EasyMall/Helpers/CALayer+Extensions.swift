import QuartzCore

extension CALayer {
    
    /// Returns CAGradientLayer for input values
    static func shimmerGradient(
        frame: CGRect,
        colors: [CGColor],
        startPoint: CGPoint,
        endPoint: CGPoint,
        locations: [NSNumber],
        cornerRadius: CGFloat
    ) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        gradient.frame = frame
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.locations = locations
        gradient.cornerRadius = cornerRadius
        
        return gradient
    }
    
    /// Adds CABasicAnimation with `locations` keyPath to CALayer
    func addShimmerAnimation(
        fromValue: [NSNumber],
        toValue: [NSNumber],
        duration: CFTimeInterval,
        repeatCount: Float = .infinity,
        isRemovedOnCompletion: Bool = false
    ) {
        let animation = CAAnimation
            .locationsAnimation(fromValue: fromValue,
                                   toValue: toValue,
                                   duration: duration,
                                   repeatCount: repeatCount,
                                   isRemovedOnCompletion: isRemovedOnCompletion)
        
        add(animation, forKey: Const.shimmerAnimationKey)
    }
    
    func addShadow(
        color: CGColor? = nil,
        offset: CGSize = CGSize(width: 0.0, height: -3.0),
        radius: CGFloat = 3.0,
        opacity: Float = .zero
    ) {
        shadowColor = color
        shadowOffset = offset
        shadowRadius = radius
        shadowOpacity = opacity
    }
}
