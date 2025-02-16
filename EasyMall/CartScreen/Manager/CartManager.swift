import Foundation
import Combine

// MARK: - Protocols

protocol CartManagerProtocol {
    var cartItemsSubject: CurrentValueSubject<[CartItem], Never> { get }
    
    func isProductInCart(_ productId: Int) -> Bool
    func getProductQuantity(_ productId: Int) -> Int
    func addProduct(_ product: Product)
    func removeProduct(_ productId: Int)
    func increaseQuantity(of productId: Int)
    func decreaseQuantity(of productId: Int)
    func clearCart()
}

final class CartManager: CartManagerProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var cartItemsSubject: CurrentValueSubject<[CartItem], Never> = .init([])
    
    // MARK: - Private Properties
    
    private let storage: CartStorageProtocol
    
    // MARK: - Initializers
    
    init(storage: CartStorageProtocol = CartStorage()) {
        self.storage = storage
        self.cartItemsSubject.send(storage.load())
    }
    
    // MARK: - Methods
    
    func isProductInCart(_ productId: Int) -> Bool {
        cartItemsSubject.value.contains { $0.product.id == productId }
    }
    
    func getProductQuantity(_ productId: Int) -> Int {
        cartItemsSubject.value.first { $0.product.id == productId }?.quantity ?? .zero
    }
    
    func addProduct(_ product: Product) {
        var updatedList = cartItemsSubject.value
        
        if let index = updatedList.firstIndex(where: { $0.product.id == product.id }) {
            updatedList[index].quantity += 1
        } else {
            updatedList.append(CartItem(product: product, quantity: 1))
        }
        
        cartItemsSubject.send(updatedList)
        storage.save(updatedList)
    }
    
    func removeProduct(_ productId: Int) {
        var updatedList = cartItemsSubject.value
        updatedList.removeAll { $0.product.id == productId }
        
        cartItemsSubject.send(updatedList)
        storage.save(updatedList)
    }
    
    func increaseQuantity(of productId: Int) {
        var updatedList = cartItemsSubject.value
        
        if let index = updatedList.firstIndex(where: { $0.product.id == productId }) {
            updatedList[index].quantity += 1
            cartItemsSubject.send(updatedList)
            storage.save(updatedList)
        }
    }
    
    func decreaseQuantity(of productId: Int) {
        var updatedList = cartItemsSubject.value
        
        if let index = updatedList.firstIndex(where: { $0.product.id == productId }) {
            
            if updatedList[index].quantity > 1 {
                updatedList[index].quantity -= 1
            } else {
                updatedList.remove(at: index)
            }
            
            cartItemsSubject.send(updatedList)
            storage.save(updatedList)
        }
    }
    
    func clearCart() {
        cartItemsSubject.send([])
        storage.clear()
    }
}
