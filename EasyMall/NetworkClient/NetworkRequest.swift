import Foundation

// MARK: - HTTP Method Enum

enum HttpMethod: String {
    case get = "GET"
}

// MARK: - NetworkRequest Protocol

protocol NetworkRequest {
    var baseEndpoint: String { get }
    var path: String { get }
    var parameters: [(String, Any)] { get }
    var httpMethod: HttpMethod { get }
}

// MARK: - Default Request Values

extension NetworkRequest {
    var baseEndpoint: String { Const.baseEndpoint }
    var httpMethod: HttpMethod { .get }
    
    func makeURLRequest() -> URLRequest? {
        var components = URLComponents(string: baseEndpoint + path)
        
        components?.queryItems = parameters.map {
            URLQueryItem(name: $0.0, value: String(describing: $0.1))
        }
        
        guard let url = components?.url else { return nil }
        let request = URLRequest(url: url)
        
        return request
    }
}