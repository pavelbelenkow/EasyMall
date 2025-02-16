import UIKit

// MARK: - Delegates

protocol SearchHistoryTableViewControllerDelegate: AnyObject {
    func getRecentSearches() -> [SearchQuery]
    func didTapSearchQuery(at index: Int)
}

final class SearchHistoryTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    weak var interactionDelegate: SearchHistoryTableViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
    
    // MARK: - Overridden Methods
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        interactionDelegate?.getRecentSearches().count ?? .zero
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let clockIcon = UIImage(systemName: Const.clockIcon)
        let cellData = interactionDelegate?.getRecentSearches()
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Const.searchHistoryCellReuseIdentifier,
            for: indexPath
        )
        
        cell.backgroundColor = .systemGray6
        cell.selectionStyle = .none
        
        cell.textLabel?.text = cellData?[indexPath.row].filters.title
        cell.textLabel?.textColor = .white
        
        cell.imageView?.image = clockIcon
        cell.imageView?.tintColor = .white
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactionDelegate?.didTapSearchQuery(at: indexPath.row)
        dismiss(animated: true)
    }
}

// MARK: - Setup UI

private extension SearchHistoryTableViewController {
    
    func setupAppearance() {
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Const.searchHistoryCellReuseIdentifier)
    }
}

