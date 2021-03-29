//
//  NetworkStocksManager.swift
//  YaStockPrices
//
//  Created by Elena Shurygina on 18.03.2021.
//

import UIKit

protocol NetworkStocksManagerDelegate: class {
    func updateInterface (_: NetworkStocksManager, with stockModel: StockModel)
    func updateFavouriteStocks (_: NetworkStocksManager, with stockModel: StockModel)
    func notUpdate (_: NetworkStocksManager)
    func updatePrices (_: NetworkStocksManager, with stockModel: StockModel)
}

class NetworkStocksManager {
    
    weak var delegate: NetworkStocksManagerDelegate?
    
    enum RequestType {
        case start (index: String, favouriteStocksCD: Array<FavouriteStock>)
        case fragment (fragment: String)
        case update (tickerName: String)
    }
    
    func fetch (forRequestType requestType: RequestType) {
        switch requestType {
        case .start(let index, let favouriteStocks):
            guard let urlString = "https://finnhub.io/api/v1/index/constituents?symbol=\(index)&token=\(apiKeyFinnhub)".addingPercentEncoding ( withAllowedCharacters: .urlQueryAllowed ) else {return}
            performRequestStart(withUrlString: urlString, withFavouriteStocks: favouriteStocks)
            for stock in favouriteStocks { performRequestFavFromCoreData(withFavouriteStock: stock) }
        case .fragment(let fragment):
            guard fragment.isEmpty == false else {return}
            guard let urlString = "https://finnhub.io/api/v1/search?q=\(fragment)&token=\(apiKeyFinnhub)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
            performRequestFinded (withUrlString: urlString)
        case .update(let tickerName):
            performRequest(withTickerName: tickerName, withIsFavourite: false, withIsUpdate: true)
        }
    }
    
    fileprivate func performRequestStart (withUrlString urlString: String, withFavouriteStocks favouriteStocks: Array<FavouriteStock>) {
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                guard let startStocks = self.parseJSONStart(withData: data) else {return}
                for symbol in startStocks {
                    let isFavourite = favouriteStocks.contains(where: {$0.tickerName == symbol})
                    self.performRequest(withTickerName: symbol, withIsFavourite: isFavourite, withIsUpdate: false)
                }
            }
        }
        task.resume()
    }
    
    fileprivate func performRequestIndex (withUrlString urlString: String) {
        
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                guard let startStocks = self.parseJSONStart(withData: data) else {return}
                for symbol in startStocks {
                    self.performRequest(withTickerName: symbol, withIsFavourite: false,withIsUpdate: false)
                }
            }
        }
        task.resume()
    }
    
    fileprivate func performRequestFavFromCoreData (withFavouriteStock favouriteStock: FavouriteStock) {
        guard let tickerName = favouriteStock.tickerName else {return}
        guard let urlString = "https://cloud.iexapis.com/stable/stock/\(tickerName)/quote?filter=symbol,companyName,latestPrice,change,changePercent&token=\(apiKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                guard var stockModel = self.parseJSON(withData: data) else {return}
                if favouriteStock.imageData != nil {
                    stockModel.image = UIImage (data: favouriteStock.imageData!)
                    stockModel.isFavourite = true
                    self.delegate?.updateFavouriteStocks(self, with: stockModel)
                } else {
                    guard let urlStringLogo = "https://cloud.iexapis.com/stable/stock/\(tickerName)/logo?&token=\(apiKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        self.delegate?.updateFavouriteStocks(self, with: stockModel)
                        return
                    }
                    guard let urlLogo = URL (string: urlStringLogo) else {
                        self.delegate?.updateFavouriteStocks(self, with: stockModel)
                        return
                    }
                    let sessionLogo = URLSession(configuration: .default)
                    let taskLogo = sessionLogo.dataTask(with: urlLogo) {(dataLogo, responseLogo, errorLogo) in
                        if let dataLogo = dataLogo, (responseLogo as? HTTPURLResponse)?.statusCode == 200 {
                            if let image = self.parseJSONImage(withData: dataLogo) {
                                stockModel.image = image
                                self.delegate?.updateFavouriteStocks(self, with: stockModel)
                            }
                        }
                    }
                    taskLogo.resume()
                }
            }
        }
        task.resume()
    }
    
    fileprivate func performRequest (withTickerName tickerName: String, withIsFavourite isFavourite: Bool, withIsUpdate isUpdate: Bool) {
        guard let urlString = "https://cloud.iexapis.com/stable/stock/\(tickerName)/quote?filter=symbol,companyName,latestPrice,change,changePercent&token=\(apiKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                guard var stockModel = self.parseJSON(withData: data) else {return}
                guard !isUpdate else {
                    self.delegate?.updatePrices(self, with: stockModel)
                    return
                }
                stockModel.isFavourite = isFavourite
                guard let urlStringLogo = "https://cloud.iexapis.com/stable/stock/\(tickerName)/logo?&token=\(apiKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    self.delegate?.updateInterface(self, with: stockModel)
                    return
                }
                guard let urlLogo = URL (string: urlStringLogo) else {
                    self.delegate?.updateInterface(self, with: stockModel)
                    return
                }
                let sessionLogo = URLSession(configuration: .default)
                let taskLogo = sessionLogo.dataTask(with: urlLogo) {(dataLogo, responseLogo, errorLogo) in
                    if let dataLogo = dataLogo, (responseLogo as? HTTPURLResponse)?.statusCode == 200 {
                        if let image = self.parseJSONImage(withData: dataLogo) {
                            stockModel.image = image
                            self.delegate?.updateInterface(self, with: stockModel)
                        }
                    }
                }
                taskLogo.resume()
            } else {
                self.delegate?.notUpdate(self)
            }
        }
        task.resume()
    }
    
    fileprivate func performRequestFinded (withUrlString urlString: String) {
        
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                guard var findedStocks = self.parseJSONFinded(withData: data) else {return}
                findedStocks = findedStocks.map({ (value: String) -> String in
                    let index = value.firstIndex(of: ".") ?? value.endIndex
                    let beginning = value[..<index]
                    return String(beginning)
                })
                findedStocks = Array ( Set (findedStocks) )
                let count = findedStocks.count
                if count > 40 {
                    findedStocks.removeLast(count - 40)
                }
                if findedStocks.isEmpty {
                    self.delegate?.notUpdate(self)
                }
                for symbol in findedStocks {
                    self.performRequest(withTickerName: symbol, withIsFavourite: false, withIsUpdate: false)
                }
            }
        }
        task.resume()
    }
    
    func parseJSONStart (withData data: Data) -> [String]? {
        let decoder = JSONDecoder()
        do {
            let startStocks = try decoder.decode (IndicesConstituents.self, from: data)
            return startStocks.constituents
        } catch let error as NSError {
            print (error.localizedDescription)
        }
        return nil
    }
    
    func parseJSONFinded (withData data: Data) -> [String]? {
        let decoder = JSONDecoder()
        do {
            let finded = try decoder.decode (FindedFinnhub.self, from: data)
            let findedTickers = finded.result.filter( {$0.type == "Common Stock"} ).reduce( into: [] ) { results, element in results.append(element.symbol)}
            return findedTickers
        } catch let error as NSError {
            print (error.localizedDescription)
        }
        return nil
    }
    
    func parseJSON (withData data: Data) -> StockModel? {
        let decoder = JSONDecoder()
        do {
            let stockData = try decoder.decode (StockData.self, from: data)
            guard let stockModel = StockModel(stockData: stockData) else { return nil}
            return stockModel
        } catch let error as NSError {
            print (error)
        }
        
        return nil
    }
    
    func parseJSONImage (withData data: Data) -> UIImage? {
        let decoder = JSONDecoder()
        do {
            let logoDict = try decoder.decode (Dictionary<String, String>.self, from: data)
            guard let urlString = logoDict["url"] else { return nil }
            guard let url = URL (string: urlString) else { return nil }
            guard let data = try? Data(contentsOf: url) else { return nil }
            guard let image = UIImage(data: data) else { return nil }
            return image
        } catch let error as NSError {
            print (error)
        }
        return nil
    }
}
