import UIKit

// MARK: - Shimmer Animation

extension UIView {
    
    func addShimmerAnimation(
        colors: [CGColor] = UIColor.defaultShimmerColors,
        borderWidth: CGFloat = .zero,
        borderColors: [CGColor] = UIColor.defaultShimmerBorderColors,
        startPoint: CGPoint = .defaultShimmerStartPoint,
        endPoint: CGPoint = .defaultShimmerEndPoint,
        locations: [NSNumber] = NSNumber.defaultShimmerLocations,
        fromValues: [NSNumber] = NSNumber.defaultShimmerFromValues,
        toValues: [NSNumber] = NSNumber.defaultShimmerToValues,
        duration: CFTimeInterval = .defaultShimmerDuration
    ) {
        let gradient = CALayer.shimmerGradient(
            frame: bounds.inset(by: .makeInsets(for: borderWidth)),
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint,
            locations: locations,
            cornerRadius: layer.cornerRadius
        )
        
        gradient.addShimmerAnimation(
            fromValue: fromValues,
            toValue: toValues,
            duration: duration
        )
        
        let borderGradient = CALayer.shimmerGradient(
            frame: bounds,
            colors: borderColors,
            startPoint: startPoint,
            endPoint: endPoint,
            locations: locations,
            cornerRadius: layer.cornerRadius
        )
        
        borderGradient.addShimmerAnimation(
            fromValue: fromValues,
            toValue: toValues,
            duration: duration
        )
        
        layer.addSublayer(borderGradient)
        borderGradient.addSublayer(gradient)
    }
    
    func removeShimmerAnimation() {
        guard
            let gradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer })
        else { return }
        gradientLayer.removeFromSuperlayer()
    }
}

// MARK: - Affine Transform Animations

extension UIView {
    
    func animateSelection(completion: (() -> Void)?) {
        animateScale(to: 0.95) {
            self.animateScale(completion: completion)
        }
    }
    
    func animateHighlight() {
        animateScale(to: 0.95)
    }
    
    func animateUnhighlight() {
        animateScale()
    }
}

// MARK: - Find Parent ViewController

extension UIView {
    
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

// MARK: - Private Methods

private extension UIView {
    
    func animateScale(
        to scale: CGFloat = 1.0,
        duration: TimeInterval = 0.2,
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            completion?()
        }
    }
}
