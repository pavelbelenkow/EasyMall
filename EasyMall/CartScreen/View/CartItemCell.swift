import UIKit

// MARK: - Delegates

protocol CartItemCellDelegate: AnyObject {
    func increaseQuantityTapped(for item: CartItem)
    func decreaseQuantityTapped(for item: CartItem)
    func removeItemTapped(for item: CartItem)
}

final class CartItemCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var productImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .systemGray3
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = Const.buttonCornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.font = .boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Const.plusTitle, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 22)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(increaseButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Const.minusTitle, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 22)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(decreaseButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: Const.trachIcon)
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var quantityControlStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [decreaseButton, quantityLabel, increaseButton])
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = Const.buttonCornerRadius
        view.axis = .horizontal
        view.spacing = Const.spacingSmall
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [priceLabel, nameLabel, quantityControlStackView])
        view.axis = .vertical
        view.spacing = Const.spacingSmall
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var currentImageUrl: String?
    private var item: CartItem?
    
    // MARK: - Properties
    
    weak var delegate: CartItemCellDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellState()
    }
}

// MARK: - Setup UI
 
private extension CartItemCell {
    
    func setupAppearance() {
        contentView.addSubview(productImageView)
        contentView.addSubview(mainStackView)
        contentView.addSubview(removeButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.spacingTen),
            productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 150),
            productImageView.heightAnchor.constraint(equalToConstant: 150),
            
            mainStackView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Const.spacingTen),
            mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.spacingTen),
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 44),
            removeButton.heightAnchor.constraint(equalToConstant: 44),
            
            mainStackView.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -Const.spacingTen)
        ])
    }
    
    func resetCellState() {
        if let currentImageUrl {
            ImageLoader.shared.cancelLoading(for: currentImageUrl)
        }
        
        currentImageUrl = nil
        productImageView.image = nil
        productImageView.backgroundColor = .clear
        
        productImageView.removeShimmerAnimation()
    }
    
    func loadAndSetupImage(_ url: String) {
        let loadImageUrl = url
        
        productImageView.addShimmerAnimation(borderWidth: 1)
        isUserInteractionEnabled = false
        
        ImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self, currentImageUrl == loadImageUrl else { return }
            
            productImageView.removeShimmerAnimation()
            productImageView.image = image
            isUserInteractionEnabled = true
        }
    }
    
    func updateDecreaseButtonState() {
        guard let item else { return }
        decreaseButton.isEnabled = item.quantity > 1
    }
}

// MARK: - Obj-C Private Methods

@objc
private extension CartItemCell {
    
    func increaseButtonTapped() {
        guard let item else { return }
        delegate?.increaseQuantityTapped(for: item)
    }
    
    func decreaseButtonTapped() {
        guard let item else { return }
        delegate?.decreaseQuantityTapped(for: item)
    }
    
    func removeButtonTapped() {
        guard let item else { return }
        delegate?.removeItemTapped(for: item)
    }
}

// MARK: - Methods

extension CartItemCell {
    
    func configure(with item: CartItem) {
        self.item = item
        nameLabel.text = item.product.title
        quantityLabel.text = "\(item.quantity)"
        
        if let price = item.product.priceWithCurrency() {
            priceLabel.text = "Price: \(price)"
        }
        
        currentImageUrl = item.product.images.first
        loadAndSetupImage(item.product.images.first ?? "")
        updateDecreaseButtonState()
    }
}
