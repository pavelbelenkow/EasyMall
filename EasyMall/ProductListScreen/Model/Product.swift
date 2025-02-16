import Foundation

struct Product: Codable {
    let id: Int
    let title: String
    let price: Int
    let description: String
    let images: [String]
    let category: Category
}

// MARK: - Methods

extension Product {
    
    func priceWithCurrency() -> String? {
        NumberFormatter
            .currencyFormatter
            .string(from: price as NSNumber)
    }
    
    func productCardText() -> String {
        guard let price = priceWithCurrency() else { return "" }
        
        let productCardText = """
        Title: \(title)
        Category: \(category)
        Description: \(description)
        Price: \(price)
        """
        
        return productCardText
    }
}

extension Product: Hashable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
