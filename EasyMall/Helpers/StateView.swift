import UIKit

final class StateView: UIView {
    
    // MARK: - Private Properties
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle(Const.tryAgainTitle, for: .normal)
        button.layer.borderWidth = Const.repeatButtonBorderWidth
        button.layer.cornerRadius = Const.buttonCornerRadius
        button.isHidden = true
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    
    var retryAction: (() -> Void)? {
        didSet {
            actionButton.isHidden = retryAction == nil
        }
    }
    
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

private extension StateView {
    
    func setupAppearance() {
        setupMessageLabel()
        setupActionButton()
        setupActivityIndicator()
    }
    
    func setupMessageLabel() {
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
    }
    
    func setupActionButton() {
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func setupActivityIndicator() {
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16)
        ])
    }
    
    @objc func actionButtonTapped() {
        retryAction?()
    }
}

// MARK: - Methods

extension StateView {
    
    func configure(for state: State) {
        switch state {
        case .idle, .loadingMore, .loaded:
            isHidden = true
            
        case .loading:
            isHidden = false
            activityIndicator.startAnimating()
            messageLabel.text = Const.loadingTitle
            messageLabel.isHidden = false
            actionButton.isHidden = true
            
        case .empty:
            isHidden = false
            activityIndicator.stopAnimating()
            messageLabel.text = Const.emptyDataTitle
            messageLabel.isHidden = false
            actionButton.isHidden = true
            
        case .error(let message):
            isHidden = false
            activityIndicator.stopAnimating()
            messageLabel.text = message
            messageLabel.isHidden = false
            actionButton.isHidden = retryAction == nil
        }
    }
}
