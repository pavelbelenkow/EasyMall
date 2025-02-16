import Combine

protocol CartViewModelProtocol: ObservableObject {
    var cartSubject: CurrentValueSubject<[CartItem], Never> { get }
    var totalPriceSubject: CurrentValueSubject<String, Never> { get }
    var shouldNavigateToProductSubject: PassthroughSubject<Int, Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func increaseQuantity(for productId: Int)
    func decreaseQuantity(for productId: Int)
    func removeItem(for productId: Int)
    func clearCart()
    func shareCart() -> String
    func selectProduct(with productId: Int)
}

final class CartViewModel: CartViewModelProtocol {
    
    // MARK: - Subjects Properties
    
    private(set) var cartSubject: CurrentValueSubject<[CartItem], Never> = .init([])
    private(set) var totalPriceSubject: CurrentValueSubject<String, Never> = .init("0 $")
    private(set) var shouldNavigateToProductSubject: PassthroughSubject<Int, Never> = .init()
    
    // MARK: - Private Properties
    
    private let cartManager: CartManagerProtocol
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(cartManager: CartManagerProtocol = CartManager()) {
        self.cartManager = cartManager
        setupBindings()
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        cartManager
            .cartItemsSubject
            .sink { [weak self] items in
                guard let self else { return }
                
                cartSubject.send(items)
                updateTotalPrice()
            }
            .store(in: &cancellables)
    }
    
    private func updateTotalPrice() {
        let total = cartSubject.value.reduce(0) { $0 + ($1.product.price * $1.quantity) }
        totalPriceSubject.send("\(total) $")
    }
    
    // MARK: - Methods
    
    func increaseQuantity(for productId: Int) {
        cartManager.increaseQuantity(of: productId)
    }
    
    func decreaseQuantity(for productId: Int) {
        cartManager.decreaseQuantity(of: productId)
    }
    
    func removeItem(for productId: Int) {
        cartManager.removeProduct(productId)
    }
    
    func clearCart() {
        cartManager.clearCart()
    }
    
    func shareCart() -> String {
        let itemsText = cartSubject.value.map { item in
            guard let price = item.product.priceWithCurrency() else { return "" }
            return "\(item.product.title) — \(item.quantity) шт. за \(price)"
        }.joined(separator: "\n")
        
        return "🛒 My cart:\n\n\(itemsText)\n\nTotal - \(totalPriceSubject.value)"
    }

    func selectProduct(with productId: Int) {
        shouldNavigateToProductSubject.send(productId)
    }
}
