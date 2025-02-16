import Foundation

// MARK: - State Enum

enum State: Equatable {
    case idle
    case loading
    case loadingMore
    case loaded
    case empty
    case error(String)
}
