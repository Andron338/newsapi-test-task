//
//  NewsService.swift
//  News List
//
//  Created by Andrian Nebeso on 2/12/21.
//

import Foundation

class NewsService {
    enum FetchType {
        case firstLoad
        case refresh
        case pagination
    }
    
    private let apiRouter = ApiRouter()
    
    private var pageNumber = 1
    
    private init() {}
    
    static let shared = NewsService()
    
    static let jsonDecoder: JSONDecoder = {
     let jsonDecoder = JSONDecoder()
     jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
     jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
      return jsonDecoder
    }()
    
    private func fetchData(using url: URL, completion: (@escaping (NewsResponse)->())) {
        URLSession.shared.dataTask(with: url) {
            (data, response, err) in
            guard let data = data else { return }
            do {
                let downloadedArticles = try NewsService.jsonDecoder.decode(NewsResponse.self, from: data)
                
                completion(downloadedArticles)
                
            } catch let jsonError {
                print("Error serializing json:", jsonError)
            }
        }.resume()
    }
    
    private func fetchNews(completion: (@escaping (NewsResponse)->())) {
        if let url = apiRouter.getNewsUrl() {
            fetchData(using: url, completion: completion)
        }
    }
    
    private func fetchNews(at page: Int, completion: (@escaping (NewsResponse)->())) {
        if let url = apiRouter.getNewsUrl(on: page) {
            fetchData(using: url, completion: completion)
        }
    }
    
    func fetchData(using fetchType: FetchType, completion: (@escaping (NewsResponse)->())) {
        switch fetchType {
        case .firstLoad, .refresh:
            pageNumber = 1
            
            fetchNews(completion: completion)
        case .pagination:
            pageNumber += 1
            
            fetchNews(at: pageNumber, completion: completion)
        }
    }
    
    func fetchData(containing text: String, completion: (@escaping (NewsResponse)->())) {
        if let url = apiRouter.getNewsUrl(containing: text) {
            fetchData(using: url, completion: completion)
        }
    }
}
