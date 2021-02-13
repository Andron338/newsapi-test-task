//
//  NewsTableViewCell.swift
//  News List
//
//  Created by Andrian Nebeso on 2/11/21.
//

import UIKit
import Kingfisher

class NewsTableViewCell: UITableViewCell {
    @IBOutlet private weak var sourceNameLabel: UILabel!
    @IBOutlet private weak var articleTitleLabel: UILabel!
    @IBOutlet private weak var articleDescriptionLabel: UILabel!
    @IBOutlet private weak var articleImageView: UIImageView!
    @IBOutlet private weak var publishedOnDateLabel: UILabel!
    
    weak var article: Article? {
        didSet {
            setupArticle()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        articleImageView.image = nil
    }
    
    private func setupArticle() {
        guard let article = article else { return }
        
        sourceNameLabel.text = article.source?.name
        articleTitleLabel.text = article.title
        articleDescriptionLabel.text = article.description
        publishedOnDateLabel.text = article.getPublishedAtDateFormatted()
        articleImageView.kf.setImage(with: article.urlToImage)
    }
}
