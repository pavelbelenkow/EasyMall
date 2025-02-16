import Foundation
import Combine

// MARK: - Protocols

protocol ProductViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var productSubject: CurrentValueSubject<Product?, Never> { get }
    var isProductInCartSubject: CurrentValueSubject<Bool, Never> { get }
    var productQuantitySubject: CurrentValueSubject<Int, Never> { get }
    var shouldNavigateSubject: CurrentValueSubject<Bool, Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func getProduct()
    func getProductCardText() -> String
    func toggleProductInCart()
    func increaseProductQuantity()
    func decreaseProductQuantity()
}

final class ProductViewModel: ProductViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject: CurrentValueSubject<State, Never> = .init(.idle)
    private(set) var productSubject: CurrentValueSubject<Product?, Never> = .init(nil)
    private(set) var isProductInCartSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private(set) var productQuantitySubject: CurrentValueSubject<Int, Never> = .init(.zero)
    private(set) var shouldNavigateSubject: CurrentValueSubject<Bool, Never> = .init(false)
    
    // MARK: - Private Properties
    
    private let productListService: ProductListServiceProtocol
    private let cartManager: CartManagerProtocol
    private var productId: Int?
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(
        productListService: ProductListServiceProtocol = ProductListService(),
        cartManager: CartManagerProtocol = CartManager(),
        productId: Int
    ) {
        self.productListService = productListService
        self.cartManager = cartManager
        self.productId = productId
        
        setupBindings()
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        productSubject
            .compactMap { $0?.id }
            .sink { [weak self] id in
                guard let self else { return }
                
                isProductInCartSubject.send(self.cartManager.isProductInCart(id))
                productQuantitySubject.send(self.cartManager.getProductQuantity(id))
            }
            .store(in: &cancellables)
        
        cartManager
            .cartItemsSubject
            .sink { [weak self] items in
                guard
                    let self,
                    let productId = productSubject.value?.id
                else { return }
                
                let isInCart = cartManager.isProductInCart(productId)
                let quantity = cartManager.getProductQuantity(productId)
                
                isProductInCartSubject.send(isInCart)
                productQuantitySubject.send(quantity)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    func getProduct() {
        guard
            let productId,
            stateSubject.value != .loading
        else { return }
        
        stateSubject.send(.loading)
        
        productListService
            .fetchProduct(by: productId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        stateSubject.send(.error(failure.localizedDescription))
                    }
                }, receiveValue: { [weak self] product in
                    guard let self else { return }
                    
                    productSubject.send(product)
                    stateSubject.send(productSubject.value != nil ? .loaded : .empty)
                })
            .store(in: &cancellables)
    }
    
    func getProductCardText() -> String {
        guard let text = productSubject.value?.productCardText() else { return "" }
        return text
    }
    
    func toggleProductInCart() {
        guard let product = productSubject.value else { return }
        
        if isProductInCartSubject.value {
            shouldNavigateSubject.send(true)
        } else {
            cartManager.addProduct(product)
        }
    }
    
    func increaseProductQuantity() {
        guard let productId = productSubject.value?.id else { return }
        cartManager.increaseQuantity(of: productId)
    }
    
    func decreaseProductQuantity() {
        guard let productId = productSubject.value?.id else { return }
        cartManager.decreaseQuantity(of: productId)
    }
}
