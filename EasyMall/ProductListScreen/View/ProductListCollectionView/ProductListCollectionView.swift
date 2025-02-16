import UIKit

// MARK: - Delegates

protocol ProductListCollectionViewDelegate: AnyObject {
    func didScrollToBottomCollectionView()
    func didTapProduct(at index: Int)
}

final class ProductListCollectionView: UICollectionView {
    
    // MARK: - Typealias Properties
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Product>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Product>
    
    // MARK: - Private Properties
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private var diffableDataSource: DataSource?
    
    // MARK: - Properties
    
    weak var interactionDelegate: ProductListCollectionViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupAppearance()
        makeDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension ProductListCollectionView {
    
    func setupAppearance() {
        backgroundColor = .clear
        
        register(
            ProductListCollectionViewCell.self,
            forCellWithReuseIdentifier: Const.productCollectionViewCellReuseIdentifier
        )
        
        register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: Const.productCollectionViewFooterReuseIdentifier
        )
        
        allowsMultipleSelection = false
        showsVerticalScrollIndicator = false
        
        delegate = self
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func makeDataSource() {
        diffableDataSource = DataSource(
            collectionView: self,
            cellProvider: { collectionView, indexPath, product in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Const.productCollectionViewCellReuseIdentifier,
                    for: indexPath
                ) as? ProductListCollectionViewCell
                
                cell?.configure(with: product)
                
                return cell
            }
        )
        
        diffableDataSource?
            .supplementaryViewProvider = { collectionView, kind, indexPath in
                let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: Const.productCollectionViewFooterReuseIdentifier,
                    for: indexPath
                )
                
                footerView.addSubview(self.activityIndicatorView)
                self.activityIndicatorView.frame = footerView.bounds
                self.activityIndicatorView.color = .white
                
                return footerView
            }
    }
}

// MARK: - Methods

extension ProductListCollectionView {
    
    func applySnapshot(for products: [Product]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.zero])
        snapshot.appendItems(products)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func updateActivityIndicator(for state: State) {
        activityIndicatorView.isHidden = state != .loadingMore
        state != .loadingMore ? activityIndicatorView.stopAnimating() : activityIndicatorView.startAnimating()
    }
}

// MARK: - UICollectionViewDelegate Methods

extension ProductListCollectionView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if contentHeight > height && offsetY > contentHeight - height {
            interactionDelegate?.didScrollToBottomCollectionView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        cell.animateSelection {
            self.interactionDelegate?.didTapProduct(at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.animateHighlight()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.animateUnhighlight()
    }
}
