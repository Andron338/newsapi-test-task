//
//  ApiRouter.swift
//  News List
//
//  Created by Andrian Nebeso on 2/12/21.
//

import Foundation

class ApiRouter {
    enum Endpoints {
        case topHeadlines
        case everything
        case source
        
        var baseURL:URL {URL(string: "https://newsapi.org/v2/")!}
        
        var path: String {
            switch self {
            case .topHeadlines:
                return "\(baseURL)top-headlines"
            case .everything:
                return "\(baseURL)everything"
            case .source:
                return "\(baseURL)sources"
            }
        }
    }
    
    private let apiKey = "74e6f8f8bbd64dae83fca3d42902429d"
    private let pageSize = 20
    
    func getNewsUrl() -> URL? {
        return URL(string: "\(Endpoints.topHeadlines.path)?country=us&pageSize=\(pageSize)&apiKey=\(apiKey)")
    }
    
    func getNewUrl(on page: Int) -> URL? {
        return URL(string: "\(Endpoints.topHeadlines.path)?country=us&pageSize=\(pageSize)&page=\(page)&apiKey=\(apiKey)")
    }
}
