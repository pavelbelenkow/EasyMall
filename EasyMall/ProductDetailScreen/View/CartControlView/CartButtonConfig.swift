import UIKit

enum CartButtonConfig {
    case inCart
    case notInCart

    var title: String {
        switch self {
        case .inCart: return Const.toCartTitle
        case .notInCart: return Const.addToCartTitle
        }
    }

    var titleColor: UIColor {
        switch self {
        case .inCart: return .systemGray5
        case .notInCart: return .white
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .inCart: return .white
        case .notInCart: return .systemPurple
        }
    }
}