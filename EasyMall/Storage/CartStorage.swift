import Foundation

// MARK: - Protocols

protocol CartStorageProtocol {
    func load() -> [CartItem]
    func save(_ items: [CartItem])
    func clear()
}

final class CartStorage: CartStorageProtocol {
    
    // MARK: - Private Properties
    
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Private Methods
    
    private func getFileURL() -> URL? {
        guard
            let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return nil }
        
        return directory.appendingPathComponent(Const.cartFileName)
    }
    
    // MARK: - Methods
    
    func load() -> [CartItem] {
        guard
            let url = getFileURL(),
            let data = try? Data(contentsOf: url)
        else { return [] }
        
        do {
            return try decoder.decode([CartItem].self, from: data)
        } catch {
            print("❌ Ошибка при загрузке: \(error)")
            return []
        }
    }
    
    func save(_ items: [CartItem]) {
        do {
            guard let url = getFileURL() else { return }
            
            let data = try encoder.encode(items)
            try data.write(to: url)
        } catch {
            print("❌ Ошибка при сохранении: \(error)")
        }
    }
    
    func clear() {
        guard let url = getFileURL() else { return }
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("❌ Ошибка при очистке файла: \(error)")
        }
    }
}
