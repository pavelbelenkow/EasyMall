import Foundation

struct CartItem: Codable, Hashable {
    let product: Product
    var quantity: Int
}
