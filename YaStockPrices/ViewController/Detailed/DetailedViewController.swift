//
//  DetailedViewController.swift
//  YaStockPrices
//
//  Created by Elenasshu on 28.03.2021.
//

import UIKit

class DetailedViewController: UIViewController {

    var stockModel: StockModel?
    
    @IBOutlet weak var chartButton: UIButton!{
        didSet {
            chartButton.titleLabel?.textColor = UIColor(named: "TextColor")
        }
    }
    @IBOutlet weak var summaryButton: UIButton! {
        didSet {
            summaryButton.titleLabel?.textColor = UIColor(named: "Lightgray")
        }
    }
    @IBOutlet weak var newsButton: UIButton! {
        didSet {
            newsButton.titleLabel?.textColor = UIColor(named: "Lightgray")
        }
    }
    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var newsView: UIView!
    
    private var selectedButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(named: "TextColor")
        selectedButton = chartButton
        
        chartView.alpha = 1
        summaryView.alpha = 0
        newsView.alpha = 0
    }
    
    @IBAction func buttonAction(_ sender: UIButton){
        selectedButton.titleLabel?.textColor = UIColor(named: "Lightgray")
        
        sender.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        sender.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)

        selectedButton = sender
        
        
        switch sender {
        case chartButton:
            chartView.alpha = 1
            summaryView.alpha = 0
            newsView.alpha = 0
        case summaryButton:
            chartView.alpha = 0
            summaryView.alpha = 1
            newsView.alpha = 0
        case newsButton:
            chartView.alpha = 0
            summaryView.alpha = 0
            newsView.alpha = 1
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case "ShowChart":
            let chartVC = segue.destination as! ChartViewController
            chartVC.stockModel = stockModel
        case "ShowSummary":
            let summaryVC = segue.destination as! SummaryTableViewController
            summaryVC.stockModel = stockModel
        case "ShowNews":
            let newsVC = segue.destination as! NewsViewController
            newsVC.stockModel = stockModel
        default:
            return
        }
    }
}
