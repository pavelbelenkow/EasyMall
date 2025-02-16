import UIKit

final class ImageGalleryCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .systemGray3
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
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

private extension ImageGalleryCell {
    
    func setupAppearance() {
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func resetCellState() {
        if let currentImageUrl {
            ImageLoader.shared.cancelLoading(for: currentImageUrl)
        }
        
        currentImageUrl = nil
        imageView.image = nil
        imageView.backgroundColor = .clear
        
        removeShimmerAnimation()
    }
    
    func loadAndSetupImage(_ url: String) {
        let loadImageUrl = url
        
        addShimmerAnimation(borderWidth: 1)
        isUserInteractionEnabled = false
        
        ImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self, currentImageUrl == loadImageUrl else { return }
            
            removeShimmerAnimation()
            imageView.image = image
            isUserInteractionEnabled = true
        }
    }
}

// MARK: - Methods

extension ImageGalleryCell {
    
    func configure(with url: String) {
        currentImageUrl = url
        loadAndSetupImage(url)
    }
}
