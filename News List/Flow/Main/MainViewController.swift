//
//  MainViewController.swift
//  News List
//
//  Created by Andrian Nebeso on 2/11/21.
//

import UIKit
import SafariServices

class MainViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var dataSource: [Article] = []
    
    private(set) var isLoadingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSeachBar()
        
        getData(for: .firstLoad)
    }
    
    private func setupTableView() {
        tableView.keyboardDismissMode = .onDrag
        
        let cellNib = UINib(nibName: String(describing: NewsTableViewCell.self), bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: String(describing: NewsTableViewCell.self))
    }
    
    private func setupSeachBar() {
        searchBar.backgroundImage = UIImage()
    }
    
    private func getImageFromCache(with url: URL?) -> UIImage? {
        guard let url = url else { return nil }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.imageCache.object(forKey: url.absoluteString as NSString)
    }
    
    private func getData(for fetchType: NewsService.FetchType) {
        switch fetchType {
        case .firstLoad, .refresh:
            dataSource = []
        default:
            break
        }
        
        isLoadingData = true
        
        NewsService.shared.fetchDataUsing(fetchType: fetchType) { [weak self] newsResponse in
            guard let self = self, let articles = newsResponse.articles else { return }
            
            DispatchQueue.main.async {
                self.isLoadingData = false
                self.dataSource.append(contentsOf: articles)
                self.tableView.reloadData()
            }
        }
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell,
              let articleUrl = cell.article?.url else { return }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let safariViewController = SFSafariViewController(url: articleUrl)
        
        present(safariViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.isNearBottomEdge(distance: 20) && !isLoadingData {
            getData(for: .pagination)
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsTableViewCell.self), for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        cell.article = dataSource[indexPath.row]
        cell.setupImage(with: getImageFromCache(with: cell.article?.urlToImage))
        
        return cell
    }
}

extension MainViewController: UISearchBarDelegate {

}
