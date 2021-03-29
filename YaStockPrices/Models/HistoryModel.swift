//
//  HistoryModel.swift
//  YaStockPrices
//
//  Created by Elenasshu on 28.03.2021.
//

import Charts

struct HistoryModel {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard timeString != nil else { return dateString }
        return timeString!
    }
    
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
