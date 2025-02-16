import Foundation

// MARK: - Protocols

protocol SearchHistoryStorageProtocol {
    var recentSearches: [SearchQuery] { get }
    func addSearchQuery(filters: ProductFilters)
}

final class SearchHistoryStorage: SearchHistoryStorageProtocol {
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Properties
    
    var recentSearches: [SearchQuery] {
        loadHistory().sorted { $0.usageCount > $1.usageCount }
    }
    
    // MARK: - Private Methods
    
    private func loadHistory() -> [SearchQuery] {
        guard
            let data = userDefaults.data(forKey: Const.recentSearchesStorageKey)
        else { return [] }
        
        let history = (try? decoder.decode([SearchQuery].self, from: data)) ?? []
        
        return history.sorted {
            if $0.usageCount == $1.usageCount {
                return $0.timestamp > $1.timestamp
            }
            return $0.usageCount > $1.usageCount
        }
    }
    
    private func saveHistory(_ history: [SearchQuery]) {
        if let data = try? encoder.encode(history) {
            userDefaults.set(data, forKey: Const.recentSearchesStorageKey)
        }
    }
    
    private func isExpired(_ timestamp: Date) -> Bool {
        guard
            let expirationDate = Calendar.current.date(
                byAdding: .day,
                value: -Const.expirationDays,
                to: Date()
            )
        else { return false }
        
        return timestamp < expirationDate
    }
    
    // MARK: - Methods
    
    func addSearchQuery(filters: ProductFilters) {
        guard
            let title = filters.title,
            !title.isEmpty
        else { return }
        
        let newQuery = SearchQuery(filters: filters, timestamp: Date(), usageCount: 1)
        var history = loadHistory()
        
        if let index = history.firstIndex(of: newQuery) {
            history[index].usageCount += 1
            history[index].timestamp = Date()
        } else {
            history.insert(newQuery, at: .zero)
        }
        
        history.removeAll { isExpired($0.timestamp) }
        
        if history.count > Const.maxRecentSearches {
            history.removeLast()
        }
        
        saveHistory(history)
    }
}
