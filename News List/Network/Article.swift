//
//  Article.swift
//  News List
//
//  Created by Andrian Nebeso on 2/12/21.
//

import Foundation

class NewsResponse: Codable {
    let articles: [Article]?
    let totalResults: Int?
}

class Article: Codable {
    let source : Source?
    let title: String?
    let description: String?
    let author: String?
    let url: URL?
    let urlToImage: URL?
    let publishedAt: Date?
    let content: String?
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        return dateFormatter
    }
    
    func getPublishedAtDateFormatted() -> String? {
        guard let publishedAt = publishedAt else { return nil }
        
        return dateFormatter.string(from: publishedAt)
    }
}

class Source: Codable {
    let id: String?
    let name: String?
    let description: String?
    let country: String?
    let category: String?
    let url: URL?
}
