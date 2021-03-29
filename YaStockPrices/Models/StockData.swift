//
//  StockData.swift
//  YaStockPrices
//
//  Created by Elena Shurygina on 18.03.2021.
//

import Foundation

// MARK: - Indices Constituents Get a list of index's constituents. Currently support ^GSPC (S&P 500), ^NDX (Nasdaq 100), ^DJI (Dow Jones)
struct IndicesConstituents: Codable {
    let constituents: [String]
    let symbol: String
}

// MARK: - Finded from Finnhub
struct FindedFinnhub: Codable {
    let count: Int
    let result: [Result]
}

struct Result: Codable {
    let description, displaySymbol, symbol: String
    let type: String
    let primary: [String]?
}

struct StockData: Codable {
    var symbol: String
    var companyName: String
    var latestPrice: Double
    var change: Double?
    var changePercent: Double?
}

// MARK: - HistoryElement
struct HistoryData: Codable {
    let close, high, low, open: Double
    let symbol: String
    let volume: Int
    let id: String
    let key: String
    let subkey, date: String
    let updated: Int
    let changeOverTime, marketChangeOverTime, uOpen, uClose: Double
    let uHigh, uLow: Double
    let uVolume: Int
    let fOpen, fClose, fHigh, fLow: Double
    let fVolume: Int
    let label: String
    let change, changePercent: Double
}

typealias History = [HistoryData]

//MARK: - HistoryDayElement

struct HistoryDayData: Codable {
    let date, minute, label: String
    let high, low, open, close: Double?
    let average: Double?
    let volume: Int
    let notional: Double
    let numberOfTrades: Int
}

typealias HistoryDay = [HistoryDayData]
