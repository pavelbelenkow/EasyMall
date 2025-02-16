import Foundation
import Combine

// MARK: - Protocols

protocol CategoryServiceProtocol {
    func fetchCategories() -> AnyPublisher<[Category], Error>
}

final class CategoryService {
    
    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let decoder: JSONDecoder
    
    // MARK: - Initialisers
    
    init(
        networkClient: NetworkClientProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkClient = networkClient
        self.decoder = decoder
    }
}

// MARK: - CategoryServiceProtocol Methods

extension CategoryService: CategoryServiceProtocol {
    
    func fetchCategories() -> AnyPublisher<[Category], any Error> {
        let request = CategoryRequest()
        
        guard let urlRequest = request.makeURLRequest() else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return networkClient
            .performRequest(with: urlRequest)
            .decode(type: [Category].self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
