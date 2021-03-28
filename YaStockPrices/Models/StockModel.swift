//
//  StockModel.swift
//  YaStockPrices
//
//  Created by Elena Shurygina on 17.03.2021.
//

import UIKit

struct StockModel {
    let companyName: String
    let tickerName: String
    var isFavourite: Bool
    var currentPrice: Double
    var currentPriceString: String {
        return "\(currentPrice)"
    }
    let currency: String
    var dayDelta: (currency: Double?, percentage: Double?)
    var dayDeltaString: (currency: String, percentage: String) {
        let dayDeltaCurrency = dayDelta.currency != nil ? String(format: "%.2f", dayDelta.currency!) : ""
        let dayDeltaPercentage = dayDelta.percentage != nil ? String(format: "%.2f", dayDelta.percentage! * 100) : ""
        return (dayDeltaCurrency, dayDeltaPercentage)
    }
    var image: UIImage?
    
    init? (stockData: StockData) {
        self.companyName = stockData.companyName
        self.tickerName = stockData.symbol
        self.isFavourite = false
        self.currentPrice = stockData.latestPrice
        self.currency = "$"
        self.dayDelta = (stockData.change, (stockData.changePercent) )
    }
}
