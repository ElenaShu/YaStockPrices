//
//  NewsTableViewCell.swift
//  YaStockPrices
//
//  Created by Elenasshu on 03.04.2021.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var textNews: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setInfo (news: NewsModel){
        
        newsImage?.image = news.image
        sourceLabel.text = news.source
        let myAttributeHeadLine = [ NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 15.0)! ]
        let myAttrString = NSMutableAttributedString(string: "\(news.headline). ", attributes: myAttributeHeadLine)
        let myAttributeSummary = [ NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 14.0)! ]
        myAttrString.append (NSAttributedString(string: news.summary, attributes: myAttributeSummary))
       
        textNews.attributedText = myAttrString
        textNews.textColor = UIColor(named: "TextColor")
        dateLabel.text = news.datetime
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
