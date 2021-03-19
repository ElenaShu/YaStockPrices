//
//  NetworkStocksManager.swift
//  YaStockPrices
//
//  Created by Elenasshu on 18.03.2021.
//

import Foundation

protocol NetworkStocksManagerDelegate: class {
    func updateInterface (_: NetworkStocksManager, with stockModel: StockModel)
}

class NetworkStocksManager {
    
    weak var delegate: NetworkStocksManagerDelegate?
    
    enum RequestType {
        case tickerName (tickerName: String)
        case companyName (companyName: String)
    }
    
    func fetchCurrentStock (forRequestType requestType: RequestType) {
        var urlString = ""
        switch requestType {
        case .tickerName (let ticker):
            urlString = "\(ticker)"
        case .companyName (let company):
            urlString = "\(company)"
        }
        performRequest (withUrlString: urlString)
    }
    
    
    fileprivate func performRequest (withUrlString urlString: String) {
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                if let stockModel = self.parseJSON(withData: data) {
                    self.delegate?.updateInterface(self, with: stockModel)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON (withData data: Data) -> StockModel? {
        let decoder = JSONDecoder()
        do {
            let stockData = try decoder.decode (StockData.self, from: data)
            guard let stockModel = StockModel(stockData: stockData) else { return nil}
            return stockModel
        } catch let error as NSError {
            print (error.localizedDescription)
        }
        return nil
    }
}
