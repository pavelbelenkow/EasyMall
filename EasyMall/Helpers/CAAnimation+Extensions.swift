import QuartzCore

extension CAAnimation {
    
    /// Returns CABasicAnimation for `locations` keyPath
    static func locationsAnimation(
        fromValue: [NSNumber],
        toValue: [NSNumber],
        duration: CFTimeInterval,
        repeatCount: Float = .infinity,
        isRemovedOnCompletion: Bool = false
    ) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: Const.locationsKeyPath)
        
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.isRemovedOnCompletion = isRemovedOnCompletion
        
        return animation
    }
}
