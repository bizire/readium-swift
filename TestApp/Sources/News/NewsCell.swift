//
//  NewsCell.swift
//  TestApp
//
//  Created by Andrei Aks on 19.09.23.
//

import UIKit
import SDWebImage
import FeedKit

final class NewsCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var newsImageView: UIImageView!
    
    @IBOutlet weak var titleLabelView: UILabel!
    @IBOutlet weak var sourceLabelView: UILabel!
    @IBOutlet weak var pubDateLabelView: UILabel!
    // MARK: - Properties
    // maybe force-unwrapping?
    var news: RSSFeedItem? {
        didSet {
            titleLabelView.text = news?.title?.replacingOccurrences(of: " - \((news?.source?.value)!)", with: "")
            pubDateLabelView.text = news?.pubDate?.formatted(date: .abbreviated, time: .omitted)
            sourceLabelView.text = news?.source?.value

//            guard let url = URL(string: "https://media.newyorker.com/photos/64dbedca70aff61ba0f99d91/1:1/w_100,c_limit/230828_r42815.jpg") else { return }
//            newsImageView.sd_setImage(with: url)
//            newsImageView.image = UIImage(named:"news-logo-1")
        }
    }
    
    func setLogo(logoImage: UIImage) {
        newsImageView.image = logoImage
    }
    
}
