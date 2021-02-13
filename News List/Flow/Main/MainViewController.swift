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
    @IBOutlet private weak var filterButton: UIButton!
    
    private lazy var refreshControl = UIRefreshControl()
    
    private var activityIndicator: UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        
        return activityIndicatorView
    }
    
    private var dataSource: [Article] = []
    private var searchTask: DispatchWorkItem?
    
    private(set) var isLoadingData = false {
        didSet {
            handleLoaderState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSeachBar()
        setupRefreshControl()
        
        getData(for: .firstLoad)
    }
    
    private func setupTableView() {
        tableView.backgroundView = activityIndicator
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        
        let cellNib = UINib(nibName: String(describing: NewsTableViewCell.self), bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: String(describing: NewsTableViewCell.self))
    }
    
    private func setupSeachBar() {
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func getData(for fetchType: NewsService.FetchType) {
        switch fetchType {
        case .firstLoad, .refresh:
            dataSource = []
        default:
            break
        }
        
        isLoadingData = true
        
        NewsService.shared.fetchData(using: fetchType) { [weak self] newsResponse in
            guard let self = self, let articles = newsResponse.articles else { return }
            
            DispatchQueue.main.async {
                self.isLoadingData = false
                self.dataSource.append(contentsOf: articles)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func handleLoaderState() {
        if isLoadingData {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        if !isLoadingData {
            getData(for: .refresh)
        } else {
            refreshControl.endRefreshing()
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
        
        return cell
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTask?.cancel()

        let task = DispatchWorkItem {
            NewsService.shared.fetchData(containing: searchText) { [weak self] newsResponse in
                guard let self = self, let articleList = newsResponse.articles else { return }
                
                self.dataSource = []
                self.dataSource.append(contentsOf: articleList)
                Dispatch.DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        searchTask = task

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: task)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" && !isLoadingData {
            getData(for: .firstLoad)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        filterButton.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        
        filterButton.isHidden = false
        
        searchTask?.cancel()
        
        if !isLoadingData {
            getData(for: .firstLoad)
        }
    }
}
