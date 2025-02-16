import Foundation

struct ProductListRequest: NetworkRequest {
    let offset: Int
    let limit: Int
    let filters: ProductFilters?
    
    var path: String { Const.productsPath }
    var parameters: [(String, Any)] {
        var parameters: [(String, Any)] = []
        
        if let title = filters?.title {
            parameters.append((Const.titleParameter, title))
        }
        
        if let priceMin = filters?.priceMin,
           let priceMax = filters?.priceMax
        {
            parameters.append((Const.minPriceParameter, priceMin))
            parameters.append((Const.maxPriceParameter, priceMax))
        }
        
        if let categoryId = filters?.categoryId {
            parameters.append((Const.categoryIdParameter, categoryId))
        }
        
        parameters.append((Const.offset, offset))
        parameters.append((Const.limit, limit))
        
        return parameters
    }
}
