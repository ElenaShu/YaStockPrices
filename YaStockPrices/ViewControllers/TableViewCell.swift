//
//  TableViewCell.swift
//  YaStockPrices
//
//  Created by Elena Shurygina on 17.03.2021.
//

import UIKit

protocol TableViewCellDelegate: class {
    func didTapFavouriteButton(_: TableViewCell, forTickerName tickerName: String)
}

class TableViewCell: UITableViewCell {

    weak var delegate: TableViewCellDelegate?
    
    @IBOutlet weak var logoImage: UIImageView! {
        didSet {
            logoImage.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var tickerNameLabel: UILabel! {
        didSet {
            tickerNameLabel.font = UIFont (name: "HelveticaNeue-Bold", size: 18)
        }
    }
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var companyNameLabel: UILabel! {
        didSet{
            companyNameLabel.font = UIFont (name: "HelveticaNeue", size: 11)
            companyNameLabel.numberOfLines = 2
            }
    }
    
    @IBOutlet weak var currentPriceLabel: UILabel!{
        didSet {
            currentPriceLabel.font = UIFont (name: "HelveticaNeue-Bold", size: 18)
        }
    }
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changePercentLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoImage.clipsToBounds = true
        logoImage.contentMode = .scaleAspectFit
        
    }
    
    func setInfo (stock: StockModel){
        
        logoImage?.image = stock.image
        companyNameLabel.text = stock.companyName
        
        tickerNameLabel.text = stock.tickerName
        favouriteButton.tintColor = stock.isFavourite ? .yellow : .gray

        currentPriceLabel.text = stock.currency + "\(stock.currentPrice)"
        
        changeLabel.text = stock.dayDeltaString.currency
        
        if stock.dayDeltaString.percentage != "" {
            changePercentLabel.text = stock.dayDeltaString.percentage + "%"
        }
        else{
            changePercentLabel.text = stock.dayDeltaString.percentage
        }
        
        if let currency = stock.dayDelta.currency {
            if (currency >= 0) {
                changeLabel.textColor = .green
                changePercentLabel.textColor = .green
            }
            else {
                changeLabel.textColor = .red
                changePercentLabel.textColor = .red
            }
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func changeFavourite(_ sender: UIButton) {
        
        guard let tickerName = tickerNameLabel.text else { return }
        delegate?.didTapFavouriteButton(self, forTickerName: tickerName)
    }
    
}
