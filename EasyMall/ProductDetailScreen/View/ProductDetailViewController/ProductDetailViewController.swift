import UIKit

final class ProductDetailViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var imageGalleryView: ImageGalleryView = {
        let galleryView = ImageGalleryView()
        galleryView.translatesAutoresizingMaskIntoConstraints = false
        return galleryView
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .left
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .systemGreen
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cartControlView: CartControlView = {
        let view = CartControlView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stateView: StateView = {
        let view = StateView()
        view.isHidden = true
        view.retryAction = { [weak self] in
            self?.viewModel.getProduct()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: any ProductViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: any ProductViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupAppearance()
        bindViewModel()
        viewModel.getProduct()
    }
}

// MARK: - Setup UI

private extension ProductDetailViewController {
    
    func setupAppearance() {
        view.backgroundColor = .systemGray5
        setupShareButton()
        setupImageGalleryView()
        setupCategoryLabel()
        setupDescriptionLabel()
        setupPriceLabel()
        setupCartControlView()
        setupStateView()
    }
    
    func setupShareButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Const.shareIcon),
            style: .plain,
            target: self,
            action: #selector(didTapShareButton)
        )
    }
    
    func setupImageGalleryView() {
        view.addSubview(imageGalleryView)
        
        NSLayoutConstraint.activate([
            imageGalleryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageGalleryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageGalleryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageGalleryView.heightAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func setupCategoryLabel() {
        view.addSubview(categoryLabel)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: imageGalleryView.bottomAnchor, constant: Const.spacingMedium),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.spacingMedium),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.spacingMedium)
        ])
    }
    
    func setupDescriptionLabel() {
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: Const.spacingSmall),
            descriptionLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor)
        ])
    }
    
    func setupPriceLabel() {
        view.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Const.spacingMedium),
            priceLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor)
        ])
    }
    
    func setupCartControlView() {
        view.addSubview(cartControlView)
        
        NSLayoutConstraint.activate([
            cartControlView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cartControlView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            cartControlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cartControlView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupStateView() {
        view.addSubview(stateView)
        
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupNavigationTitle(with text: String) {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.lineBreakMode = .byTruncatingTail
        navigationItem.titleView = titleLabel
    }
}

// MARK: - Private Methods

private extension ProductDetailViewController {
    
    func bindViewModel() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.productSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                guard let self, let product else { return }
                updateUI(with: product)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.isProductInCartSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inCart in
                self?.cartControlView.configure(inCart: inCart)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.productQuantitySubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quantity in
                self?.cartControlView.updateQuantity(with: quantity)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.shouldNavigateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] should in
                if should {
                    self?.navigateToCart()
                }
            }
            .store(in: &viewModel.cancellables)
    }
    
    func handleStateChange(_ state: State) {
        stateView.configure(for: state)
        navigationItem.rightBarButtonItem?.isEnabled = state == .loaded
        [
            imageGalleryView, categoryLabel, descriptionLabel,
            priceLabel, cartControlView
        ].forEach { $0.isHidden = state != .loaded }
    }
    
    func updateUI(with product: Product) {
        setupNavigationTitle(with: product.title)
        imageGalleryView.updateImages(product.images)
        
        categoryLabel.text = product.category.name
        descriptionLabel.text = product.description
        priceLabel.text = product.priceWithCurrency()
    }
    
    func navigateToCart() {
        guard let navigationController else { return }
        
        let viewModel = CartViewModel()
        let viewController = CartViewController(viewModel: viewModel)
        var viewControllers = navigationController.viewControllers
        
        viewControllers.removeLast()
        viewControllers.append(viewController)
        
        navigationController.setViewControllers(viewControllers, animated: true)
    }
}

// MARK: - Obj-C Private Methods

@objc
private extension ProductDetailViewController {
    
    func didTapShareButton() {
        let productCardText = viewModel.getProductCardText()
        let activityVC = UIActivityViewController(activityItems: [productCardText], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact, .saveToCameraRoll]
        
        present(activityVC, animated: true)
    }
}

// MARK: - CartControlViewDelegate Methods

extension ProductDetailViewController: CartControlViewDelegate {
    
    func didTapAddToCartButton() {
        viewModel.toggleProductInCart()
    }
    
    func didTapDecreaseButton() {
        viewModel.decreaseProductQuantity()
    }
    
    func didTapIncreaseButton() {
        viewModel.increaseProductQuantity()
    }
}
