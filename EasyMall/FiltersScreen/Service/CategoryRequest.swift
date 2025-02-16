import Foundation

struct CategoryRequest: NetworkRequest {
    var path: String { Const.categoriesPath }
    var parameters: [(String, Any)] { [] }
}
