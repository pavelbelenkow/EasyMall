import UIKit

final class CategoriesCollectionView: UICollectionView {
    
    // MARK: - Private Properties
    
    private var categories: [Category] = []
    private var selectedCategoryId: Int?
    
    // MARK: - Properties
    
    var onCategorySelected: ((Int) -> Void)?
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero, collectionViewLayout: CategoriesCollectionView.createLayout())
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension CategoriesCollectionView {
    
    func configureCollectionView() {
        backgroundColor = .clear
        register(CategoryCell.self, forCellWithReuseIdentifier: Const.categoriesCollectionViewReuseIdentifier)
        dataSource = self
        delegate = self
    }
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(Const.oneHundredSize),
            heightDimension: .absolute(Const.fortySize)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Const.fortySize)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(Const.spacingSmall)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Const.spacingSmall
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Methods

extension CategoriesCollectionView {
    
    func updateCategories(_ categories: [Category], selectedCategoryId: Int?) {
        self.categories = categories
        self.selectedCategoryId = selectedCategoryId
        reloadData()
    }
}

// MARK: - UICollectionViewDataSource Methods

extension CategoriesCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Const.categoriesCollectionViewReuseIdentifier,
                for: indexPath
            ) as? CategoryCell
        else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.row]
        let isSelected = category.id == selectedCategoryId
        cell.configure(with: category, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate Methods

extension CategoriesCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategoryId = categories[indexPath.row].id
        onCategorySelected?(selectedCategoryId!)
        reloadData()
    }
}
