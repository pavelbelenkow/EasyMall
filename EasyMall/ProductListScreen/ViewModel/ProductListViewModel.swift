import Foundation
import Combine

// MARK: - Protocols

protocol ProductListViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var productsSubject: CurrentValueSubject<[Product], Never> { get }
    var filtersSubject: CurrentValueSubject<ProductFilters, Never> { get }
    var recentSearchesSubject: CurrentValueSubject<[SearchQuery], Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func getProducts()
    func loadMoreProducts()
    func setSearchQuery(for filters: ProductFilters)
    func filterSuggestions(for searchText: String?)
    func didSelectSearchQuery(at index: Int)
    func setSearchFilters(_ filters: ProductFilters)
}

final class ProductListViewModel: ProductListViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject: CurrentValueSubject<State, Never> = .init(.idle)
    private(set) var productsSubject: CurrentValueSubject<[Product], Never> = .init([])
    private(set) var filtersSubject: CurrentValueSubject<ProductFilters, Never> = .init(ProductFilters())
    private(set) var recentSearchesSubject: CurrentValueSubject<[SearchQuery], Never> = .init([])
    
    // MARK: - Private Properties
    
    private var offset: Int = .zero
    private var limit: Int = Const.limitTen
    private var hasMorePages: Bool = true
    
    private let productListService: ProductListServiceProtocol
    private let searchHistoryStorage: SearchHistoryStorageProtocol
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(
        service: ProductListServiceProtocol = ProductListService(),
        storage: SearchHistoryStorageProtocol = SearchHistoryStorage()
    ) {
        self.productListService = service
        self.searchHistoryStorage = storage
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Private Methods
    
    private func resetPagination() {
        offset = .zero
        hasMorePages = true
        productsSubject.send([])
    }
    
    // MARK: - Methods
    
    func getProducts() {
        guard
            stateSubject.value != .loading,
            hasMorePages
        else { return }
        
        let isPaginating = offset > .zero
        stateSubject.send(isPaginating ? .loadingMore : .loading)
        
        productListService
            .fetchProducts(
                offset: offset,
                limit: limit,
                filters: filtersSubject.value
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        stateSubject.send(.error(failure.localizedDescription))
                    }
                }, receiveValue: { [weak self] newProducts in
                    guard let self else { return }
                    
                    if offset == .zero {
                        productsSubject.send(newProducts)
                    } else {
                        let allProducts = productsSubject.value + newProducts
                        productsSubject.send(allProducts)
                    }
                    
                    stateSubject.send(productsSubject.value.isEmpty ? .empty : .loaded)
                    hasMorePages = newProducts.count == limit
                })
            .store(in: &cancellables)
    }
    
    func loadMoreProducts() {
        guard
            stateSubject.value != .loading,
            stateSubject.value != .loadingMore,
            hasMorePages
        else { return }

        offset += 10
        getProducts()
    }
    
    func setSearchQuery(for filters: ProductFilters) {
        guard filters != filtersSubject.value else { return }
        
        searchHistoryStorage.addSearchQuery(filters: filters)
        filtersSubject.send(filters)
        recentSearchesSubject.send(searchHistoryStorage.recentSearches)
        
        resetPagination()
        getProducts()
    }

    
    func filterSuggestions(for searchText: String?) {
        guard let searchText, !searchText.isEmpty else {
            recentSearchesSubject.send(searchHistoryStorage.recentSearches)
            return
        }

        let filteredSuggestions = searchHistoryStorage.recentSearches.filter {
            $0.filters.title?.localizedCaseInsensitiveContains(searchText) == true
        }

        recentSearchesSubject.send(filteredSuggestions)
    }

    
    func didSelectSearchQuery(at index: Int) {
        let selectedQuery = recentSearchesSubject.value[index]
        setSearchQuery(for: selectedQuery.filters)
    }

    
    func setSearchFilters(_ filters: ProductFilters) {
        setSearchQuery(for: filters)
    }
}
