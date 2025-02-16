import UIKit

final class ImageLoader {
    
    // MARK: - Static Properties
    
    static let shared = ImageLoader()
    
    // MARK: - Private Properties
    
    private let placeholder = UIImage(systemName: Const.imagePlaceholder)
    private let maxRetryAttempts = 3
    private let retryDelay: TimeInterval = 2.0
    private let cache = NSCache<NSString, UIImage>()
    private let lockQueue = DispatchQueue(label: "imageLoader.lockQueue")
    private var activeTasks = [String: URLSessionDataTask]()
    
    private let session: URLSession
    
    // MARK: - Private Initialisers
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - Private Methods

private extension ImageLoader {
    
    func cleanURLString(_ urlString: String) -> String {
        urlString.trimmingCharacters(in: CharacterSet(charactersIn: "[]\""))
    }
    
    func getCachedImage(for urlString: String) -> UIImage? {
        cache.object(forKey: NSString(string: urlString))
    }
    
    func shouldStartTask(for urlString: String) -> Bool {
        lockQueue.sync {
            if activeTasks[urlString] != nil {
                return false
            }
            return true
        }
    }
    
    func createDataTask(
        for url: URL,
        urlString: String,
        attempt: Int,
        completion: @escaping (UIImage?) -> Void
    ) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        
        return session.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }
            
            removeActiveTask(for: urlString)
            
            if error != nil, attempt < maxRetryAttempts {
                retryLoading(
                    urlString: urlString,
                    attempt: attempt,
                    completion: completion
                )
                return
            }
            
            let image = processDownloadedImage(data: data, for: urlString)
            DispatchQueue.main.async { completion(image) }
        }
    }
    
    func storeActiveTask(_ task: URLSessionDataTask, for urlString: String) {
        lockQueue.sync {
            activeTasks[urlString] = task
        }
    }
    
    func removeActiveTask(for urlString: String) {
        lockQueue.sync {
            activeTasks[urlString] = nil
        }
    }
    
    func retryLoading(
        urlString: String,
        attempt: Int,
        completion: @escaping (UIImage?) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
            self?.loadImage(
                from: urlString,
                attempt: attempt + 1,
                completion: completion
            )
        }
    }
    
    func processDownloadedImage(data: Data?, for urlString: String) -> UIImage? {
        guard
            let data,
            let image = UIImage(data: data)
        else {
            return placeholder
        }
        
        cache.setObject(image, forKey: NSString(string: urlString))
        return image
    }
}

// MARK: - Methods

extension ImageLoader {
    
    func loadImage(
        from urlString: String,
        attempt: Int = 0,
        completion: @escaping (UIImage?) -> Void
    ) {
        let cleanedURLString = cleanURLString(urlString)
        
        if let cachedImage = getCachedImage(for: cleanedURLString) {
            DispatchQueue.main.async { completion(cachedImage) }
            return
        }
        
        guard let url = URL(string: cleanedURLString) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        guard shouldStartTask(for: cleanedURLString) else { return }
        
        let task = createDataTask(for: url, urlString: cleanedURLString, attempt: attempt, completion: completion)
        
        storeActiveTask(task, for: cleanedURLString)
        task.resume()
    }
    
    func cancelLoading(for urlString: String) {
        lockQueue.sync {
            activeTasks[urlString]?.cancel()
            activeTasks[urlString] = nil
        }
    }
}
