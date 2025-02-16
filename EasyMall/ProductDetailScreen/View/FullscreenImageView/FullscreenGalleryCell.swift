import UIKit

final class FullscreenGalleryCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.maximumZoomScale = 3.0
        view.minimumZoomScale = 1.0
        view.zoomScale = 1.0
        view.bouncesZoom = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .systemGray3
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var currentImageUrl: String?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellState()
    }
}

// MARK: - Setup UI

private extension FullscreenGalleryCell {
    
    func setupAppearance() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        scrollView.frame = contentView.bounds
        imageView.frame = scrollView.bounds
        
        addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
    }
    
    func resetCellState() {
        if let currentImageUrl {
            ImageLoader.shared.cancelLoading(for: currentImageUrl)
        }
        
        currentImageUrl = nil
        imageView.image = nil
        imageView.backgroundColor = .clear
        
        imageView.removeShimmerAnimation()
    }
    
    func loadAndSetupImage(_ url: String) {
        let loadImageUrl = url
        
        imageView.addShimmerAnimation(borderWidth: 1)
        isUserInteractionEnabled = false
        
        ImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self, currentImageUrl == loadImageUrl else { return }
            
            imageView.removeShimmerAnimation()
            imageView.image = image
            isUserInteractionEnabled = true
        }
    }
    
    @objc func handleDoubleTap() {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            scrollView.setZoomScale(2.5, animated: true)
        }
    }
}

// MARK: - Methods

extension FullscreenGalleryCell {
    
    func configure(with url: String) {
        currentImageUrl = url
        loadAndSetupImage(url)
    }
}

// MARK: - UIScrollViewDelegate Methods

extension FullscreenGalleryCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
}
