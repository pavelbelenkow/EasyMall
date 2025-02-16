import Foundation
import Combine

// MARK: - Protocols

protocol ProductListServiceProtocol {
    func fetchProducts(offset: Int, limit: Int, filters: ProductFilters?) -> AnyPublisher<[Product], Error>
    func fetchProduct(by id: Int) -> AnyPublisher<Product, Error>
}

final class ProductListService {
    
    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let decoder: JSONDecoder
    
    // MARK: - Initializers
    
    init(
        networkClient: NetworkClientProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkClient = networkClient
        self.decoder = decoder
    }
}

// MARK: - ProductListServiceProtocol Methods

extension ProductListService: ProductListServiceProtocol {
    
    func fetchProducts(
        offset: Int,
        limit: Int,
        filters: ProductFilters?
    ) -> AnyPublisher<[Product], any Error> {
        let request = ProductListRequest(offset: offset, limit: limit, filters: filters)
        
        guard let urlRequest = request.makeURLRequest() else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return networkClient
            .performRequest(with: urlRequest)
            .decode(type: [Product].self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchProduct(by id: Int) -> AnyPublisher<Product, any Error> {
        let request = ProductRequest(id: id)
        
        guard let urlRequest = request.makeURLRequest() else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return networkClient
            .performRequest(with: urlRequest)
            .decode(type: Product.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
