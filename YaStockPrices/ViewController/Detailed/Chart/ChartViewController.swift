//
//  chartView.swift
//  YaStockPrices
//
//  Created by Elenasshu on 03.04.2021.
//

import UIKit
import Charts

class ChartViewController: UIViewController, ChartViewDelegate {

    var stockModel: StockModel?
    private var arrayHistoryModel = [HistoryModel]()

    var lineChart = LineChartView()
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var halfAYearButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var twoYearsButton: UIButton!
    
    private var selectedDayButton = UIButton()
    private var selectedTimeInterval = "1D"
    
    var networkChartManager = NetworkChartManager ()
    
    override func viewDidLoad () {
        super.viewDidLoad()

        if let stockModel = self.stockModel {
            priceLabel.text = "$" + stockModel.currentPriceString
            changeLabel.text = "$\(stockModel.dayDeltaString.currency) (\(stockModel.dayDeltaString.percentage)%)"
            if let currency = stockModel.dayDelta.currency {
                if (currency >= 0) {
                    changeLabel.textColor = .green
                }
                else {
                    changeLabel.textColor = .red
                }
            }
        }
        
        networkChartManager.delegate = self
        selectedDayButton = dayButton
        selectedDayButton.backgroundColor = UIColor(named: "TextColor")
        selectedDayButton.titleLabel?.textColor = UIColor(named: "BackgroundColorEvenCell")
        if let tickerName = stockModel?.tickerName {
            networkChartManager.fetch(forTickerName: tickerName, forTimeInterval: "1D")
        }
        
        lineChart.delegate = self
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        guard let stockModel = stockModel else { return }
        selectedDayButton.backgroundColor = UIColor(named: "BackgroundColorEvenCell")
        selectedDayButton.titleLabel?.textColor = UIColor(named: "TextColor")
        
        selectedTimeInterval = sender.titleLabel!.text!
        sender.backgroundColor = UIColor(named: "TextColor")
        sender.titleLabel?.textColor = UIColor(named: "BackgroundColorEvenCell")
        selectedDayButton = sender
        
        var timeInterval = sender.titleLabel!.text!
        if timeInterval.count == 1 {
            timeInterval.insert("1", at: timeInterval.startIndex)
        }
        networkChartManager.fetch(forTickerName: stockModel.tickerName, forTimeInterval: timeInterval)
    }
    
    private func updateChartData () {
        
        chartView.setScaleEnabled(true)
        
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 3600
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        guard let minHistoryModel = arrayHistoryModel.min(by: { a, b in
                                                        if a.price != nil && b.price != nil {
                                                            return a.price! < b.price!
                                                        }
                                                        return false }) else { return }
        guard let minPrice = minHistoryModel.price else { return }
        leftAxis.axisMinimum = minPrice - 0.5
        guard let maxHistoryModel = arrayHistoryModel.max(by: { a, b in
                                                        if a.price != nil && b.price != nil {
                                                            return a.price! < b.price!
                                                        }
                                                        return false }) else { return }
        guard let maxPrice = maxHistoryModel.price else { return }
        
        leftAxis.axisMaximum = maxPrice + 0.5
        
        
        leftAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)

        chartView.rightAxis.enabled = false
        
        chartView.legend.enabled = false
        
        var chartDataEntry = [ ChartDataEntry ]()
        for historyModel in arrayHistoryModel {
            if historyModel.timeString != nil {
                if let price = historyModel.price {
                    chartDataEntry.append(ChartDataEntry(x: historyModel.time, y: price))
                    xAxis.valueFormatter = DateValueFormatter(format: "HH:mm")
                }
            }
            else {
                if let price = historyModel.price {
                    chartDataEntry.append(ChartDataEntry(x: historyModel.date, y: price))
                    xAxis.valueFormatter = DateValueFormatter(format: "dd MMM YY")
                }
            }
        }
        let set = LineChartDataSet(entries: chartDataEntry, label: "Price")
        
        set.fillAlpha = 1
        set.drawFilledEnabled = true
        if let color = NSUIColor(named: "TextColor") {
            set.colors = [color]
            set.setCircleColor(color)
        }
        set.fillColor = #colorLiteral(red: 0.3111782153, green: 0.3111782153, blue: 0.3111782153, alpha: 0.51)
        set.lineWidth = 2
        set.circleRadius = 1
        set.valueFont = .systemFont(ofSize: 10)

        let data = LineChartData(dataSet: set)
        chartView.data = data
    }
    
}

extension ChartViewController: NetworkChartManagerDelegate {
    func updateChart(_: NetworkChartManager, withArrayHistoryModel arrayHistoryModel: Array<HistoryModel>) {
        DispatchQueue.main.async {
            self.arrayHistoryModel = arrayHistoryModel
            self.updateChartData()
        }
    }
}
