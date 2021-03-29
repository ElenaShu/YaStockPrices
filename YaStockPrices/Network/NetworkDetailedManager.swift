//
//  NetworkDetailedManager.swift
//  YaStockPrices
//
//  Created by Elenasshu on 28.03.2021.
//

import UIKit

protocol NetworkDetailedManagerDelegate: class {
    func updateChart (_: NetworkDetailedManager, withArrayHistoryModel arrayHistoryModel: Array <HistoryModel>)
}

class NetworkDetailedManager {
    weak var delegate: NetworkDetailedManagerDelegate?
    
    func fetch (forTickerName tickerName: String, forTimeInterval timeInterval: String) {
        
        performRequest(withTickerName: tickerName, withTimeInterval: timeInterval)
        
    }
    
    fileprivate func performRequest (withTickerName tickerName: String, withTimeInterval timeInterval: String ) {
        let urlString =  "https://cloud.iexapis.com/stable/stock/\(tickerName)/chart/\(timeInterval)?&token=\(apiKey)"
        
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                var arrayHistoryModel: Array <HistoryModel>
                if timeInterval.last == "D" {
                    guard let array = self.parseJSONDay(withData: data, withTickerName: tickerName) else { return }
                    arrayHistoryModel = array
                }
                else {
                    guard let array = self.parseJSON(withData: data) else { return }
                    arrayHistoryModel = array
                }
                self.delegate?.updateChart(self, withArrayHistoryModel: arrayHistoryModel)
            }
        }
        task.resume()
    }
    
    func parseJSON (withData data: Data) -> [HistoryModel]? {
        let decoder = JSONDecoder()
        do {
            let arrayHistoryData = try decoder.decode (History.self, from: data)
            var arrayHistoryModel = [HistoryModel]()
            arrayHistoryData.forEach { historyData in
                guard let historyModel = HistoryModel(historyData: historyData) else { return }
                arrayHistoryModel.append(historyModel)
            }
            return arrayHistoryModel
        } catch let error as NSError {
            print (error)
        }
        return nil
    }
    
    func parseJSONDay (withData data: Data, withTickerName tickerName: String) -> [HistoryModel]? {
        let decoder = JSONDecoder()
        do {
            let arrayHistoryDayData = try decoder.decode (HistoryDay.self, from: data)
            var arrayHistoryModel = [HistoryModel]()
            arrayHistoryDayData.forEach { historyDayData in
                guard let historyModel = HistoryModel(historyDayData: historyDayData, tickerName: tickerName) else { return }
                arrayHistoryModel.append(historyModel)
            }
            return arrayHistoryModel
        } catch let error as NSError {
            print (error)
        }
        return nil
    }
}
