//
//  NetworkNewsManager.swift
//  YaStockPrices
//
//  Created by Elenasshu on 03.04.2021.
//

import UIKit

protocol NetworkNewsManagerDelegate: class {
    func updateNews (_: NetworkNewsManager, withArrayNewsModel arrayNewsModel: Array <NewsModel>)
}

class NetworkNewsManager {
    weak var delegate: NetworkNewsManagerDelegate?
    
    func fetch (forTickerName tickerName: String) {
        performRequestNews (withTickerName: tickerName )
    }
    
    fileprivate func performRequestNews (withTickerName tickerName: String ) {
        let urlString =  "https://cloud.iexapis.com/stable/stock/\(tickerName)/news/last/3?token=\(apiKey)"
        
        guard let url = URL (string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                var arrayNewsModel: Array <NewsModel>
                guard let array = self.parseJSONNews(withData: data) else { return }
                arrayNewsModel = array
                
                self.delegate?.updateNews(self, withArrayNewsModel: arrayNewsModel)
            }
        }
        task.resume()
    }
    
    fileprivate func parseJSONNews (withData data: Data) -> [NewsModel]? {
        let decoder = JSONDecoder()
        do {
            let arrayNewsData = try decoder.decode (News.self, from: data)
            var arrayNewsModel = [NewsModel]()
            arrayNewsData.forEach { newsData in
                guard var newsModel = NewsModel(newsElement: newsData) else { return }
                if let image = parseJSONImage(withUrlString: newsData.image) {
                    newsModel.image = image
                }
                arrayNewsModel.append(newsModel)
            }
            return arrayNewsModel
        } catch let error as NSError {
            print (error)
        }
        return nil
    }
    
    fileprivate func parseJSONImage (withUrlString urlString: String) -> UIImage? {
        
        guard let url = URL (string: urlString) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
    }
}
