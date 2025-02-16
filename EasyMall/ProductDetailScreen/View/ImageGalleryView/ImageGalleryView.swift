import UIKit

final class ImageGalleryView: UICollectionView {
    
    // MARK: - Private Properties
    
    private var images: [String] = []
    
    // MARK: - Initializers
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .zero
        layout.minimumInteritemSpacing = .zero
        
        super.init(frame: .zero, collectionViewLayout: layout)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension ImageGalleryView {
    
    func setupAppearance() {
        backgroundColor = .clear
        
        register(
            ImageGalleryCell.self,
            forCellWithReuseIdentifier: Const.imageGalleryViewCellReuseIdentifier
        )
        
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        
        dataSource = self
        delegate = self
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - Methods

extension ImageGalleryView {
    
    func updateImages(_ images: [String]) {
        self.images = images
        reloadData()
    }
}

// MARK: - UICollectionViewDataSource Methods

extension ImageGalleryView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Const.imageGalleryViewCellReuseIdentifier,
                for: indexPath
            ) as? ImageGalleryCell
        else { return UICollectionViewCell() }
        
        cell.configure(with: images[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Methods

extension ImageGalleryView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let parentView = findViewController()?.view else { return }

        let fullscreenGalleryView = FullscreenGalleryView(images: images, startIndex: indexPath.item)
        fullscreenGalleryView.delegate = self
        
        fullscreenGalleryView.dismissHandler = {
            UIView.animate(withDuration: 0.3) {
                fullscreenGalleryView.alpha = .zero
            } completion: { _ in
                fullscreenGalleryView.removeFromSuperview()
            }
        }

        fullscreenGalleryView.show(in: parentView)
    }
}

// MARK: - FullscreenGalleryViewDelegate Methods

extension ImageGalleryView: FullscreenGalleryViewDelegate {
    
    func fullscreenGalleryDidChangeIndex(to index: Int) {
        let indexPath = IndexPath(item: index, section: .zero)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}
