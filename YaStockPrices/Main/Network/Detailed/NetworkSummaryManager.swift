//
//  NetworkSummaryManager.swift
//  YaStockPrices
//
//  Created by Elenasshu on 04.04.2021.
//

import UIKit

protocol NetworkSummaryManagerDelegate: class {
    func updateSummary (_: NetworkSummaryManager, withSummaryCompany summaryCompany: SummaryCompany)
}

class NetworkSummaryManager {
    weak var delegate: NetworkSummaryManagerDelegate?
    
    func fetch (forTickerName tickerName: String) {
        performRequestSummary (withTickerName: tickerName )
    }
    
    fileprivate func performRequestSummary (withTickerName tickerName: String ) {
        let urlString = "https://cloud.iexapis.com/stable/stock/\(tickerName)/company?token=\(apiKey)" 
        
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                guard let company = self.parseJSONSummary(withData: data) else { return }
                let summaryCompany = SummaryCompany(company: company)
                self.delegate?.updateSummary(self, withSummaryCompany: summaryCompany)
            }
        }
        task.resume()
    }
    
    fileprivate func parseJSONSummary (withData data: Data) -> Company? {
        let decoder = JSONDecoder()
        do {
            let summaryData = try decoder.decode (Company.self, from: data)
            return summaryData
        } catch let error as NSError {
            print (error)
        }
        return nil
    }
}
