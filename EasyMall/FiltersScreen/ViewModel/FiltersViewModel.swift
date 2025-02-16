import Foundation
import Combine

// MARK: - Protocols

protocol FiltersViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var filtersSubject: CurrentValueSubject<ProductFilters, Never> { get }
    var categoriesSubject: CurrentValueSubject<[Category], Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func getCategories()
    func setFilters(_ filters: ProductFilters)
}

final class FiltersViewModel: FiltersViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject: CurrentValueSubject<State, Never> = .init(.idle)
    private(set) var filtersSubject: CurrentValueSubject<ProductFilters, Never> = .init(ProductFilters())
    private(set) var categoriesSubject: CurrentValueSubject<[Category], Never> = .init([])
    
    // MARK: - Private Properties
    
    private let categoryService: CategoryServiceProtocol
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(
        service: CategoryServiceProtocol = CategoryService(),
        filters: ProductFilters
    ) {
        self.categoryService = service
        self.filtersSubject.send(filters)
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Methods
    
    func getCategories() {
        guard stateSubject.value != .loading else { return }
        
        stateSubject.send(.loading)
        
        categoryService
            .fetchCategories()
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        stateSubject.send(.error(failure.localizedDescription))
                    }
                }, receiveValue: { [weak self] categories in
                    guard let self else { return }
                    
                    categoriesSubject.send(categories)
                    stateSubject.send(categoriesSubject.value.isEmpty ? .empty : .loaded)
                })
            .store(in: &cancellables)
    }
    
    func setFilters(_ filters: ProductFilters) {
        filtersSubject.send(filters)
    }
}
