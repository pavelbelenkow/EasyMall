import UIKit

// MARK: - Delegates

protocol FullscreenGalleryViewDelegate: AnyObject {
    func fullscreenGalleryDidChangeIndex(to index: Int)
}

final class FullscreenGalleryView: UIView {
    
    // MARK: - Private Properties
    
    private let collectionView: UICollectionView
    private let images: [String]
    private var currentIndex: Int
    
    private var initialTouchPoint: CGPoint = .zero
    private let dismissThreshold: CGFloat = 100
    private var isVerticalPan = false
    private var isInitialScrollDone = false
    
    // MARK: - Properties
    
    weak var delegate: FullscreenGalleryViewDelegate?
    var dismissHandler: (() -> Void)?
    
    // MARK: - Initializers
    
    init(images: [String], startIndex: Int) {
        self.images = images
        self.currentIndex = startIndex
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)
        setupAppearance()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isInitialScrollDone {
            isInitialScrollDone = true
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let indexPath = IndexPath(item: currentIndex, section: .zero)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
}

// MARK: - Setup UI

private extension FullscreenGalleryView {
    
    func setupAppearance() {
        backgroundColor = .black
        alpha = .zero
        
        collectionView.register(
            FullscreenGalleryCell.self,
            forCellWithReuseIdentifier: Const.fullscreenGalleryViewCellReuseIdentifier
        )
        
        collectionView.isPagingEnabled = true
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
}

// MARK: - Private Methods

private extension FullscreenGalleryView {
    
    func visibleCell() -> FullscreenGalleryCell? {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        guard let index = visibleIndexPaths.first else { return nil }
        return collectionView.cellForItem(at: index) as? FullscreenGalleryCell
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let cell = visibleCell() else { return }
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = gesture.location(in: self)
            isVerticalPan = false
        case .changed:
            let dx = abs(translation.x)
            let dy = abs(translation.y)
            
            if !isVerticalPan {
                let angle = atan2(dy, dx) * (180 / .pi)
                isVerticalPan = angle > 60
            }
            
            if isVerticalPan {
                let progress = abs(translation.y) / dismissThreshold
                cell.frame.origin.y = translation.y
                cell.alpha = 1 - progress * 0.5
            }
        case .ended:
            if isVerticalPan, abs(translation.y) > dismissThreshold {
                dismissHandler?()
            } else {
                UIView.animate(withDuration: 0.3) {
                    cell.frame.origin.y = .zero
                    cell.alpha = 1
                }
            }
        default:
            break
        }
    }
}

// MARK: - Methods

extension FullscreenGalleryView {
    
    func show(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
}

// MARK: - UICollectionViewDataSource Methods

extension FullscreenGalleryView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Const.fullscreenGalleryViewCellReuseIdentifier,
                for: indexPath
            ) as? FullscreenGalleryCell
        else { return UICollectionViewCell() }
        
        cell.configure(with: images[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate Methods

extension FullscreenGalleryView: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        if page != currentIndex {
            currentIndex = page
            delegate?.fullscreenGalleryDidChangeIndex(to: page)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate Methods

extension FullscreenGalleryView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }
}
