import Foundation

struct SearchQuery: Codable {
    let filters: ProductFilters
    var timestamp: Date
    var usageCount: Int
}

extension SearchQuery: Equatable {
    
    static func == (lhs: SearchQuery, rhs: SearchQuery) -> Bool {
        return lhs.filters == rhs.filters
    }
}