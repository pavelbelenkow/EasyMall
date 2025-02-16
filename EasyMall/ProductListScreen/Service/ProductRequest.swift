import Foundation

struct ProductRequest: NetworkRequest {
    let id: Int
    
    var path: String { Const.productsPath + "/\(id)" }
    var parameters: [(String, Any)] { [] }
}
