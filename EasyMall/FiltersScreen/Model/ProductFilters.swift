import Foundation

struct ProductFilters: Codable, Equatable {
    var title: String?
    var priceMin: Int?
    var priceMax: Int?
    var categoryId: Int?
}