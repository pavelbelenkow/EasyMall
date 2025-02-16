import UIKit

// MARK: - Delegates

protocol ProductListSearchControllerDelegate: AnyObject {
    func didTapCartButton()
}

final class ProductListSearchController: UISearchController {
    
    // MARK: - Private Properties
    
    private lazy var productListSearchBar = ProductListSearchBar()
    
    // MARK: - Properties
    
    weak var searchBarDelegate: ProductListSearchControllerDelegate?
    
    // MARK: - Overridden Properties
    
    override var searchBar: UISearchBar { productListSearchBar }
    
    // MARK: - Initializers
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        obscuresBackgroundDuringPresentation = false
        productListSearchBar.searchBarDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ProductListSearchBarDelegate Methods

extension ProductListSearchController: ProductListSearchBarDelegate {
    
    func didTapCartButton() {
        searchBarDelegate?.didTapCartButton()
    }
}
