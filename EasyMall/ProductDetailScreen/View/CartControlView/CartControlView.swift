import UIKit

// MARK: - Delegates

protocol CartControlViewDelegate: AnyObject {
    func didTapAddToCartButton()
    func didTapDecreaseButton()
    func didTapIncreaseButton()
}

final class CartControlView: UIView {
    
    // MARK: - Private Properties
    
    private lazy var addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = Const.buttonCornerRadius
        button.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Const.minusTitle, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 22)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapDecreaseButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Const.plusTitle, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 22)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapIncreaseButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var counterStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [decreaseButton, quantityLabel, increaseButton])
        stackView.backgroundColor = .systemGray6
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.isHidden = true
        stackView.alpha = .zero
        stackView.layer.cornerRadius = Const.buttonCornerRadius
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [counterStackView, addToCartButton])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    
    weak var delegate: CartControlViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension CartControlView {
    
    func setupAppearance() {
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func updateButtonAppearance(_ inCart: Bool) {
        let config = inCart ? CartButtonConfig.inCart : CartButtonConfig.notInCart
        addToCartButton.setTitle(config.title, for: .normal)
        addToCartButton.setTitleColor(config.titleColor, for: .normal)
        addToCartButton.backgroundColor = config.backgroundColor
    }
    
    func animateCounterStackView(visible: Bool) {
        if visible {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            } completion: { _ in
                UIView.transition(with: self.counterStackView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.counterStackView.alpha = 1
                    self.counterStackView.isHidden = false
                })
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.counterStackView.alpha = 0
            } completion: { _ in
                self.counterStackView.isHidden = true
            }
        }
    }
}

// MARK: - Private Methods

@objc
private extension CartControlView {
    
    func addToCartButtonTapped() {
        delegate?.didTapAddToCartButton()
    }
    
    func didTapDecreaseButton() {
        delegate?.didTapDecreaseButton()
    }
    
    func didTapIncreaseButton() {
        delegate?.didTapIncreaseButton()
    }
}

// MARK: - Methods

extension CartControlView {
    
    func updateQuantity(with quantity: Int) {
        quantityLabel.text = "\(quantity)"
    }
    
    func configure(inCart: Bool) {
        updateButtonAppearance(inCart)
        animateCounterStackView(visible: inCart)
    }
}
