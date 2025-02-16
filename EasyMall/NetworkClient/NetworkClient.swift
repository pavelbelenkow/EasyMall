import Foundation
import Combine

// MARK: - Protocols

protocol NetworkClientProtocol {
    func performRequest(with request: URLRequest) -> AnyPublisher<Data, Error>
}

// MARK: - NetworkClientProtocol Methods

extension URLSession: NetworkClientProtocol {
    
    func performRequest(with request: URLRequest) -> AnyPublisher<Data, Error> {
        dataTaskPublisher(for: request)
            .tryMap { output in
                guard
                    let httpResponse = output.response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    throw URLError(.badServerResponse)
                }
                
                return output.data
            }
            .eraseToAnyPublisher()
    }
}
