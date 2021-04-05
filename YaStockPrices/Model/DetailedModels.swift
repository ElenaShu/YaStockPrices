//
//  HistoryModel.swift
//  YaStockPrices
//
//  Created by Elenasshu on 28.03.2021.
//
import UIKit

//MARK: Model for Charts
struct HistoryModel {
    
    let price: Double?
    let tickerName: String
    let dateString: String
    var date: Double {
        return dateToDouble(dateString: dateString)
    }
    let timeString: String?
    var time: Double {
        return timeToDouble(timeString: timeString) ?? 0
    }
    
    init? (historyData: HistoryData) {
        self.price = historyData.close
        self.tickerName = historyData.symbol
        self.dateString = historyData.date
        self.timeString = nil
    }
    
    init? (historyDayData: HistoryDayData, tickerName: String) {
        self.price = historyDayData.close
        self.tickerName = tickerName
        self.dateString = historyDayData.date
        self.timeString = historyDayData.minute
    }
    
    func timeToDouble (timeString: String?) -> Double? {
        guard let timeString = timeString else { return nil}
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let someDateTime = formatter.date(from: timeString )
        
        return someDateTime?.timeIntervalSince1970
    }
    
    func dateToDouble (dateString: String) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let someDate = formatter.date(from: dateString )
        
        guard let resultDate = someDate?.timeIntervalSince1970 else { return 0 }
        return resultDate
    }
}

// MARK: - NewsModel
struct NewsModel {
    let datetime: String
    let headline, source: String
    let url: String
    let summary, tickerName: String
    var image: UIImage?
    
    init? (newsElement: NewsElement) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy"
        
        let today = formatter.string(from: Date())
        let yesterday = formatter.string(from: Date(timeIntervalSince1970: Double(Date().timeIntervalSince1970 - (24*60*60))))

        let date = formatter.string(from: Date(timeIntervalSince1970: Double(newsElement.datetime / 1000 )))
        if today == date {
            self.datetime = "Today"
        } else if yesterday == date {
            self.datetime = "Yesterday"
        } else {
            self.datetime = date
        }
        
        self.headline = newsElement.headline
        self.source = newsElement.source
        self.url = newsElement.url
        self.summary = newsElement.summary
        self.tickerName = newsElement.related
    }
}

// MARK: - Summary
struct SummaryCompany {
    let symbol, companyName, exchange, industry: String
    let website: String
    let description, CEO: String
    let employees: Int?
    let address: String?
    let state, city, zip, country: String?
    let phone: String?
    
    init(company: Company) {
        self.symbol = company.symbol
        self.companyName = company.companyName
        self.exchange = company.exchange
        self.industry = company.industry
        self.website = company.website
        self.description = company.description
        self.CEO = company.CEO
        self.employees = company.employees
        self.address = company.address
        self.state = company.state
        self.city = company.city
        self.zip = company.zip
        self.country = company.country
        self.phone = company.phone
    }
}
