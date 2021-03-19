//
//  StockData.swift
//  YaStockPrices
//
//  Created by Elenasshu on 18.03.2021.
//

import Foundation

struct StockData: Codable {
    var companyName: String
    var tickerName: String
    var currentPrice: Double
    var currency: String
    var dayDelta: DayDelta
}

struct DayDelta: Codable {
    var currency: Double
    var percentage: Double
}
