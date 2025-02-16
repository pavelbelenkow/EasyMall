import UIKit

final class ProductListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var productImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .systemGray3
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var productTitleLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            numberOfLines: 2,
            textInsets: .small
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var productPriceLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            textColor: .systemGreen,
            font: .boldSystemFont(ofSize: 15),
            textInsets: .small
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var productContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var currentImageUrl: String?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellState()
    }
}

// MARK: - Setup UI

private extension ProductListCollectionViewCell {
    
    func setupAppearance() {
        layer.cornerRadius = Const.collectionCellCornerRadius
        layer.masksToBounds = true
        
        setupProductContainerView()
        setupProductImageView()
        setupProductTitleLabel()
        setupProductPriceLabel()
    }
    
    func setupProductContainerView() {
        contentView.addSubview(productContainerView)
        
        NSLayoutConstraint.activate([
            productContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            productContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            productContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupProductImageView() {
        productContainerView.addSubview(productImageView)
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: productContainerView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: productContainerView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: productContainerView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalTo: productContainerView.heightAnchor, multiplier: 0.7)
        ])
    }
    
    func setupProductTitleLabel() {
        productContainerView.addSubview(productTitleLabel)
        
        NSLayoutConstraint.activate([
            productTitleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor),
            productTitleLabel.leadingAnchor.constraint(equalTo: productContainerView.leadingAnchor),
            productTitleLabel.trailingAnchor.constraint(equalTo: productContainerView.trailingAnchor)
        ])
    }
    
    func setupProductPriceLabel() {
        productContainerView.addSubview(productPriceLabel)
        
        NSLayoutConstraint.activate([
            productPriceLabel.leadingAnchor.constraint(equalTo: productContainerView.leadingAnchor),
            productPriceLabel.trailingAnchor.constraint(equalTo: productContainerView.trailingAnchor),
            productPriceLabel.bottomAnchor.constraint(equalTo: productContainerView.bottomAnchor)
        ])
    }
    
    func resetCellState() {
        if let currentImageUrl {
            ImageLoader.shared.cancelLoading(for: currentImageUrl)
        }
        
        currentImageUrl = nil
        productImageView.image = nil
        productImageView.backgroundColor = .clear
        productTitleLabel.text = nil
        productPriceLabel.text = nil
        
        removeShimmerAnimation()
    }
    
    func loadAndSetupImage(from product: Product) {
        let loadImageUrl = product.images.first
        
        addShimmerAnimation(borderWidth: 1)
        isUserInteractionEnabled = false
        
        ImageLoader.shared.loadImage(from: product.images.first ?? "") { [weak self] image in
            guard let self, currentImageUrl == loadImageUrl else { return }
            
            removeShimmerAnimation()
            productImageView.image = image
            isUserInteractionEnabled = true
        }
    }
}

// MARK: - Methods

extension ProductListCollectionViewCell {
    
    func configure(with product: Product) {
        productTitleLabel.text = product.title
        productPriceLabel.text = product.priceWithCurrency()
        currentImageUrl = product.images.first
        loadAndSetupImage(from: product)
    }
}
