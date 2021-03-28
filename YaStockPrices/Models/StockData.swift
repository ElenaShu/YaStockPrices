//
//  StockData.swift
//  YaStockPrices
//
//  Created by Elena Shurygina on 18.03.2021.
//

import Foundation

// MARK: - Indices Constituents Get a list of index's constituents. Currently support ^GSPC (S&P 500), ^NDX (Nasdaq 100), ^DJI (Dow Jones)
//https://finnhub.io/api/v1/index/constituents?symbol=^DJI&token=c191cf748v6rd7oucqhg
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

// MARK: - Company Profile from Finnhub
struct CompanyProfile: Codable {
    let country, currency, exchange, finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Int
    let name, phone: String
    let shareOutstanding: Double
    let ticker: String
    let weburl: String
}

// MARK: - Welcome
/*
 https://finnhub.io/api/v1/stock/candle?symbol=AAPL&resolution=D&from=1615298999&to=1615302599&token=c191cf748v6rd7oucqhg
 resolution - D W M
 from время начала в unix
 to время конца в unix
 
 c - Список цен закрытия для возвращенных свечей.
 h - Список высоких цен на возвращаемые свечи.
 l - Список низких цен на возвращаемые свечи.
 o - Список цен открытия возвращенных свечей.
 s - Статус ответа. Это поле может быть ok или no_data.
 t - Список отметок времени для возвращенных свечей.
 v - Список данных объема для возвращенных свечей.
 */
struct Welcome: Codable {
    let c, h, l, o: [Double]
    let s: String
    let t, v: [Int]
}

struct FindedElement: Codable {
    let symbol, cik, securityName, securityType: String
    let region, exchange, sector, currency: String
}

typealias Finded = [FindedElement]

struct StockData: Codable {
    var symbol: String
    var companyName: String
    var latestPrice: Double
    var change: Double?
    var changePercent: Double?
}

