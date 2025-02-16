import UIKit

// MARK: - Delegates

protocol ProductListSearchBarDelegate: AnyObject {
    func didTapCartButton()
}

final class ProductListSearchBar: UISearchBar {
    
    // MARK: - Private Properties
    
    private lazy var cartButton: UIButton = {
        let button = UIButton(type: .system)
        let cartIcon = UIImage(systemName: Const.cartIcon)
        button.tintColor = .white
        button.setImage(cartIcon, for: .normal)
        button.addTarget(self, action: #selector(didTapCartButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var searchTextFieldTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Properties
    
    weak var searchBarDelegate: ProductListSearchBarDelegate?
    
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

private extension ProductListSearchBar {
    
    func setupAppearance() {
        tintColor = .white
        placeholder = Const.searchBarPlaceholder
        setupCartButton()
        setupSearchTextField()
    }
    
    func setupCartButton() {
        addSubview(cartButton)
        
        NSLayoutConstraint.activate([
            cartButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            cartButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: 44),
            cartButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setupSearchTextField() {
        searchTextField.backgroundColor = .systemGray6
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        
        searchTextFieldTrailingConstraint = searchTextField
            .trailingAnchor
            .constraint(
                equalTo: cartButton.leadingAnchor,
                constant: -8
            )
        searchTextFieldTrailingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}

// MARK: - Private Methods

private extension ProductListSearchBar {
    
    func animateCartButton(isHidden: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            
            cartButton.alpha = isHidden ? 0 : 1
            searchTextFieldTrailingConstraint?.constant = isHidden ? -36 : -8
            
            layoutIfNeeded()
        }
    }
    
    @objc func didTapCartButton() {
        searchBarDelegate?.didTapCartButton()
    }
}

// MARK: - UITextFieldDelegate Methods

extension ProductListSearchBar: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateCartButton(isHidden: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateCartButton(isHidden: false)
    }
}
