//
//  TableViewCell.swift
//  YaStockPrices
//
//  Created by Elenasshu on 17.03.2021.
//

import UIKit

protocol TableViewCellDelegate: class {
    func didTapFavouriteButton(_: TableViewCell, forTickerName tickerName: String)
}

class TableViewCell: UITableViewCell {

    weak var delegate: TableViewCellDelegate?
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var tickerNameLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var dayDeltaLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setInfo (stock: StockModel){
        companyNameLabel.text = stock.companyName
        tickerNameLabel.text = stock.tickerName
        if stock.isFavourite == true {
            favouriteButton.tintColor = .yellow
        }
        else {
            favouriteButton.tintColor = .gray
        }
        if stock.currency == "₽" {
            currentPriceLabel.text = "\(stock.currentPrice)" + stock.currency
            dayDeltaLabel.text = "\(stock.dayDelta.currency)" + stock.currency + " \(stock.dayDelta.percentage)%"
        }
        else {
            currentPriceLabel.text = stock.currency + "\(stock.currentPrice)"
            dayDeltaLabel.text = stock.currency + "\(stock.dayDelta.currency) \(stock.dayDelta.percentage)%"
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
