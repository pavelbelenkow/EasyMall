import UIKit

final class CartViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var cartItemsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Const.spacingTen
        layout.minimumInteritemSpacing = Const.spacingTen
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(CartItemCell.self, forCellWithReuseIdentifier: Const.cartItemCellReuseIdentifier)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var totalPriceLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            textColor: .systemGreen,
            font: .boldSystemFont(ofSize: 18),
            alignment: .center
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var cartItems: [CartItem] = []
    
    private let viewModel: any CartViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: any CartViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        bindViewModel()
        //        viewModel.cartSubject.send(viewModel.cartSubject.value)
    }
}

// MARK: - Setup UI

private extension CartViewController {
    
    private func setupAppearance() {
        view.backgroundColor = .systemGray5
        setupNavigationBar()
        setupCartItemsCollectionView()
        setupTotalPriceLabel()
    }
    
    func setupNavigationBar() {
        title = Const.cartTitle
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: Const.shareIcon),
                style: .plain,
                target: self,
                action: #selector(shareButtonTapped)
            ),
            UIBarButtonItem(
                title: Const.clearAllTitle,
                style: .plain,
                target: self,
                action: #selector(clearButtonTapped)
            )
        ]
    }
    
    func setupCartItemsCollectionView() {
        view.addSubview(cartItemsCollectionView)
        
        NSLayoutConstraint.activate([
            cartItemsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cartItemsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cartItemsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cartItemsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTotalPriceLabel() {
        view.addSubview(totalPriceLabel)
        
        NSLayoutConstraint.activate([
            totalPriceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalPriceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalPriceLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Private Methods

private extension CartViewController {
    
    func bindViewModel() {
        viewModel.cartSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                cartItems = items
                cartItemsCollectionView.reloadData()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.totalPriceSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] price in
                self?.totalPriceLabel.text = "Total: \(price)"
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.shouldNavigateToProductSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] productId in
                self?.navigateToProductDetailViewController(with: productId)
            }
            .store(in: &viewModel.cancellables)
    }
    
    func navigateToProductDetailViewController(with id: Int) {
        guard let navigationController else { return }
        
        let viewModel = ProductViewModel(productId: id)
        let viewController = ProductDetailViewController(viewModel: viewModel)
        var viewControllers = navigationController.viewControllers
        
        viewControllers.removeLast()
        viewControllers.append(viewController)

        navigationController.setViewControllers(viewControllers, animated: true)
    }
    
    @objc func clearButtonTapped() {
        viewModel.clearCart()
    }
    
    @objc func shareButtonTapped() {
        let text = viewModel.shareCart()
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource Methods

extension CartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Const.cartItemCellReuseIdentifier,
                for: indexPath
            ) as? CartItemCell
        else {
            return UICollectionViewCell()
        }
        
        let item = cartItems[indexPath.item]
        cell.configure(with: item)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Methods

extension CartViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(width: collectionView.bounds.width, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productId = cartItems[indexPath.item].product.id
        viewModel.selectProduct(with: productId)
    }
}

// MARK: - CartItemCellDelegate Methods

extension CartViewController: CartItemCellDelegate {
    
    func increaseQuantityTapped(for item: CartItem) {
        viewModel.increaseQuantity(for: item.product.id)
    }
    
    func decreaseQuantityTapped(for item: CartItem) {
        viewModel.decreaseQuantity(for: item.product.id)
    }
    
    func removeItemTapped(for item: CartItem) {
        viewModel.removeItem(for: item.product.id)
    }
}
