import Foundation

// MARK: - Constants

enum Const {
    
    static let baseEndpoint = "https://api.escuelajs.co/api/v1"
    static let productsPath = "/products"
    static let categoriesPath = "/categories"
    
    static let titleParameter = "title"
    static let minPriceParameter = "price_min"
    static let maxPriceParameter = "price_max"
    static let categoryIdParameter = "categoryId"
    static let offset = "offset"
    static let limit = "limit"
    
    static let limitTen = 10
    
    static let spacingSmall: CGFloat = 8
    static let spacingTen: CGFloat = 10
    static let spacingMedium: CGFloat = 16
    static let fortySize: CGFloat = 40
    static let oneHundredSize: CGFloat = 100
    static let collectionCellCornerRadius: CGFloat = 15
    
    static let repeatButtonBorderWidth: CGFloat = 1
    static let buttonCornerRadius: CGFloat = 10
    
    static let cartIcon = "cart"
    static let filterIcon = "slider.horizontal.3"
    static let clockIcon = "clock.arrow.circlepath"
    static let xMarkIcon = "xmark"
    static let shareIcon = "square.and.arrow.up"
    static let trachIcon = "trash"
    
    static let mallTitle = "Mall"
    static let searchBarPlaceholder = "Search products"
    static let imagePlaceholder = "photo"
    
    static let locationsKeyPath = "locations"
    static let shimmerAnimationKey = "shimmerAnimation"
    
    static let productCollectionViewCellReuseIdentifier = "productCell"
    static let productCollectionViewFooterReuseIdentifier = "productCellFooterView"
    static let searchHistoryCellReuseIdentifier = "searchHistoryCell"
    static let categoriesCollectionViewReuseIdentifier = "categoryCell"
    static let imageGalleryViewCellReuseIdentifier = "imageGalleryCell"
    static let fullscreenGalleryViewCellReuseIdentifier = "fullscreenImageCell"
    static let cartItemCellReuseIdentifier = "cartItemCell"
    
    static let filtersTitle = "Filters"
    static let resetTitle = "Reset"
    static let allCategoriesTitle = "All Categories"
    static let nameTitle = "Title"
    static let priceTitle = "Price"
    static let titleTextFieldPlaceholder = "Write title"
    static let minPriceTextFieldPlaceholder = "From"
    static let maxPriceTextFieldPlaceholder = "To"
    static let showProductsTitle = "Show Products"
    
    static let minusTitle = "-"
    static let plusTitle = "+"
    static let addToCartTitle = "Add to Cart"
    static let toCartTitle = "To Cart"
    
    static let cartTitle = "Cart"
    static let clearAllTitle = "Clear All"
    
    static let tryAgainTitle = "Try Again"
    static let loadingTitle = "Loading..."
    static let emptyDataTitle = "No data available."
    
    static let cartFileName = "cart.json"
    static let recentSearchesStorageKey = "recentSearches"
    static let maxRecentSearches = 5
    static let expirationDays = 7
}
