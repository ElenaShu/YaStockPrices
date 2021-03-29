//
//  DateValueFormatter.swift
//  YaStockPrices
//
//  Created by Elenasshu on 29.03.2021.
//

import Charts

class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    init(format: String) {
        super.init()
        dateFormatter.dateFormat = format
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

