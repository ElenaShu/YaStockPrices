//
//  StockModel.swift
//  YaStockPrices
//
//  Created by Elenasshu on 17.03.2021.
//

import Foundation

struct StockModel {
    var companyName: String
    var tickerName: String
    var isFavourite: Bool
    var currentPrice: Double
    var currentPriceString: String {
        return "\(currentPrice)"
    }
    var currency: String
    var dayDelta: (currency: Double, percentage: Double)
    var dayDeltaString: (currency: String, percentage: String) {
        return ("\(dayDelta.currency)","\(dayDelta.percentage)")
    }
    
    init? (stockData: StockData) {
        self.companyName = stockData.companyName
        self.tickerName = stockData.tickerName
        self.isFavourite = false
        self.currentPrice = stockData.currentPrice
        self.currency = stockData.currency
        self.dayDelta = (stockData.dayDelta.currency, stockData.dayDelta.percentage)
    }
}
