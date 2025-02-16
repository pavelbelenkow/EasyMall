import UIKit

final class ProductListViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var searchHistoryTableViewController: SearchHistoryTableViewController = {
        let controller = SearchHistoryTableViewController()
        controller.interactionDelegate = self
        return controller
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = ProductListSearchController(searchResultsController: searchHistoryTableViewController)
        controller.delegate = self
        controller.searchResultsUpdater = self
        controller.searchBar.delegate = self
        controller.searchBarDelegate = self
        return controller
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        let icon = UIImage(systemName: Const.filterIcon)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.tintColor = .white
        button.contentHorizontalAlignment = .trailing
        button.setImage(icon, for: .normal)
        button.setTitle(Const.filtersTitle, for: .normal)
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return button
    }()

    private lazy var filterContainerView: UIView = createFilterContainerView()
    
    private lazy var productListCollectionView: ProductListCollectionView = {
        let view = ProductListCollectionView(frame: .zero, collectionViewLayout: makeTwoColumnLayout())
        view.interactionDelegate = self
        return view
    }()
    
    private lazy var stateView: StateView = {
        let view = StateView()
        view.isHidden = true
        view.retryAction = { [weak self] in
            self?.viewModel.getProducts()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: any ProductListViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: any ProductListViewModelProtocol) {
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
        viewModel.getProducts()
    }
}

// MARK: - Setup UI

private extension ProductListViewController {
    
    func setupAppearance() {
        view.backgroundColor = .systemGray5
        setupNavigationBar()
        setupFilterContainerView()
        setupProductListCollectionView()
        setupStateView()
    }
    
    func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        title = Const.mallTitle
        
        navigationBar.tintColor = .white
        navigationBar.prefersLargeTitles = true
        navigationBar.standardAppearance.shadowColor = .clear
        navigationBar.standardAppearance.backgroundColor = .systemGray5
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func createFilterContainerView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        
        let stackView = UIStackView(arrangedSubviews: [filterButton])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = Const.spacingSmall
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Const.spacingMedium),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Const.spacingMedium),
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Const.spacingSmall)
        ])
        
        return container
    }
    
    func setupFilterContainerView() {
        view.addSubview(filterContainerView)
        
        NSLayoutConstraint.activate([
            filterContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupProductListCollectionView() {
        view.addSubview(productListCollectionView)
        
        NSLayoutConstraint.activate([
            productListCollectionView.topAnchor.constraint(equalTo: filterContainerView.bottomAnchor),
            productListCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            productListCollectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Const.spacingMedium
            ),
            productListCollectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Const.spacingMedium
            )
        ])
    }
    
    func setupStateView() {
        view.addSubview(stateView)
        
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: filterContainerView.bottomAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func makeTwoColumnLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let numberOfItemsPerRow: CGFloat = 2
        let spacing: CGFloat = Const.spacingSmall
        let totalSpacing = spacing * (numberOfItemsPerRow - 1)
        let itemWidth = ((view.bounds.width - 32) - totalSpacing) / numberOfItemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: 300)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.footerReferenceSize = .init(width: 40, height: 40)
        return layout
    }
}

// MARK: - Private Methods

private extension ProductListViewController {
    
    func bindViewModel() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.filtersSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filters in
                self?.searchController.searchBar.text = filters.title
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.recentSearchesSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.searchHistoryTableViewController.tableView.reloadData()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.productsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                self?.productListCollectionView.applySnapshot(for: products)
            }
            .store(in: &viewModel.cancellables)
    }
    
    func handleStateChange(_ state: State) {
        productListCollectionView.isHidden = !(state == .loadingMore || state == .loaded)
        productListCollectionView.updateActivityIndicator(for: state)
        stateView.configure(for: state)
    }

    @objc func didTapFilterButton() {
        let viewModel = FiltersViewModel(filters: viewModel.filtersSubject.value)
        let viewController = FiltersViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.delegate = self
        
        if let sheet = navigationController.presentationController as? UISheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
}

//MARK: - UISearchControllerDelegate Methods

extension ProductListViewController: UISearchControllerDelegate {
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}

//MARK: - UISearchResultsUpdating Methods

extension ProductListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterSuggestions(for: searchController.searchBar.text)
    }
}

// MARK: - UISearchBarDelegate Methods

extension ProductListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        
        viewModel.setSearchQuery(for: ProductFilters(title: query))
        searchHistoryTableViewController.dismiss(animated: true)
    }
}

// MARK: - ProductListSearchControllerDelegate Methods

extension ProductListViewController: ProductListSearchControllerDelegate {
    
    func didTapCartButton() {
        let viewModel = CartViewModel()
        let viewController = CartViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - FiltersViewControllerDelegate Methods

extension ProductListViewController: FiltersViewControllerDelegate {
    
    func didUpdateFilters(_ filters: ProductFilters) {
        viewModel.setSearchFilters(filters)
    }
}

// MARK: - SearchHistoryTableViewControllerDelegate Methods

extension ProductListViewController: SearchHistoryTableViewControllerDelegate {
    
    func getRecentSearches() -> [SearchQuery] {
        viewModel.recentSearchesSubject.value
    }
    
    func didTapSearchQuery(at index: Int) {
        viewModel.didSelectSearchQuery(at: index)
    }
}

// MARK: - ProductListCollectionViewDelegate Methods

extension ProductListViewController: ProductListCollectionViewDelegate {
    
    func didScrollToBottomCollectionView() {
        viewModel.loadMoreProducts()
    }
    
    func didTapProduct(at index: Int) {
        let productId = viewModel.productsSubject.value[index].id
        let viewModel = ProductViewModel(productId: productId)
        let viewController = ProductDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
