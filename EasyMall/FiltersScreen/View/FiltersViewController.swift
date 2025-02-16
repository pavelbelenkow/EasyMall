import UIKit

// MARK: - Delegates

protocol FiltersViewControllerDelegate: AnyObject {
    func didUpdateFilters(_ filters: ProductFilters)
}

final class FiltersViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: Const.xMarkIcon)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Const.resetTitle, for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(resetFiltersButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var categoriesCollectionView = CategoriesCollectionView()
    
    private lazy var categoryLabel: UILabel = createSectionTitle(Const.allCategoriesTitle)
    private lazy var titleLabel: UILabel = createSectionTitle(Const.nameTitle)
    private lazy var priceLabel: UILabel = createSectionTitle(Const.priceTitle)
    
    private lazy var titleTextField: UITextField = createTextField(placeholder: Const.titleTextFieldPlaceholder)
    private lazy var minPriceTextField: UITextField = createTextField(
        placeholder: Const.minPriceTextFieldPlaceholder,
        keyboardType: .numberPad
    )
    private lazy var maxPriceTextField: UITextField = createTextField(
        placeholder: Const.maxPriceTextFieldPlaceholder,
        keyboardType: .numberPad
    )
    
    private lazy var applyFiltersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Const.showProductsTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPurple
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = Const.buttonCornerRadius
        button.addTarget(self, action: #selector(applyFiltersButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stateView: StateView = {
        let view = StateView()
        view.isHidden = true
        view.retryAction = { [weak self] in
            self?.viewModel.getCategories()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel: any FiltersViewModelProtocol
    private var selectedCategoryId: Int?
    
    // MARK: - Properties
    
    weak var delegate: FiltersViewControllerDelegate?
    
    // MARK: - Initializers
    
    init(viewModel: any FiltersViewModelProtocol) {
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
        
        viewModel.getCategories()
        categoriesCollectionView.onCategorySelected = { [weak self] categoryId in
            self?.selectedCategoryId = categoryId
        }
    }
}

// MARK: - Setup UI

private extension FiltersViewController {
    
    func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }
    
    func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.borderStyle = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = Const.buttonCornerRadius
        textField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: .zero, y: .zero, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }
    
    func setupAppearance() {
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 20
        
        setupNavigationBar()
        setupTapGestureToDismissKeyboard()
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        
        [scrollView, contentView, categoryLabel,
         categoriesCollectionView, titleLabel, titleTextField,
         priceLabel, minPriceTextField, maxPriceTextField, applyFiltersButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categoriesCollectionView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(priceLabel)
        contentView.addSubview(minPriceTextField)
        contentView.addSubview(maxPriceTextField)
        view.addSubview(applyFiltersButton)
        
        setupStateView()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: applyFiltersButton.topAnchor, constant: -Const.spacingTen),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Const.spacingMedium),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.spacingMedium),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: Const.spacingSmall),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.spacingMedium),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.spacingMedium),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: Const.spacingMedium),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.spacingMedium),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Const.spacingSmall),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.spacingMedium),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.spacingMedium),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            priceLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: Const.spacingMedium),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.spacingMedium),
            
            minPriceTextField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: Const.spacingSmall),
            minPriceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.spacingMedium),
            minPriceTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            minPriceTextField.heightAnchor.constraint(equalToConstant: 40),
            
            maxPriceTextField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: Const.spacingSmall),
            maxPriceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.spacingMedium),
            maxPriceTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            maxPriceTextField.heightAnchor.constraint(equalToConstant: 40),
            
            applyFiltersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Const.spacingMedium),
            applyFiltersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Const.spacingMedium),
            applyFiltersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Const.spacingMedium),
            applyFiltersButton.heightAnchor.constraint(equalToConstant: 50),
            
            contentView.bottomAnchor.constraint(equalTo: maxPriceTextField.bottomAnchor, constant: 20)
        ])
    }
    
    func setupNavigationBar() {
        title = Const.filtersTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: resetButton)
    }
    
    func setupTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
}

// MARK: - Private Methods

private extension FiltersViewController {
    
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
                self?.updateFilters(filters)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.categoriesSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                guard let self else { return }
                
                categoriesCollectionView.updateCategories(
                    categories,
                    selectedCategoryId: selectedCategoryId
                )
            }
            .store(in: &viewModel.cancellables)
    }
    
    func handleStateChange(_ state: State) {
        [
            categoriesCollectionView, categoryLabel, titleLabel, priceLabel,
            titleTextField, minPriceTextField, maxPriceTextField
        ].forEach {
            $0.isHidden = !(state == .loaded)
        }
        stateView.configure(for: state)
    }
    
    func updateFilters(_ filters: ProductFilters) {
        if
            let priceMin = filters.priceMin,
            let priceMax = filters.priceMax
        {
            minPriceTextField.text = String(priceMin)
            maxPriceTextField.text = String(priceMax)
        }
        
        selectedCategoryId = filters.categoryId
        titleTextField.text = filters.title
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func resetFiltersButtonTapped() {
        [
            titleTextField, minPriceTextField, maxPriceTextField
        ].forEach { $0.text = nil }
        selectedCategoryId = nil
        
        categoriesCollectionView.updateCategories(
            viewModel.categoriesSubject.value,
            selectedCategoryId: selectedCategoryId
        )
    }
    
    @objc func applyFiltersButtonTapped() {
        delegate?.didUpdateFilters(
            ProductFilters(
                title: titleTextField.text,
                priceMin: Int(minPriceTextField.text ?? "0"),
                priceMax: Int(maxPriceTextField.text ?? "0"),
                categoryId: selectedCategoryId
            )
        )
        dismiss(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate Methods

extension FiltersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
