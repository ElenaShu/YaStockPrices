//
//  SummaryView.swift
//  YaStockPrices
//
//  Created by Elenasshu on 03.04.2021.
//

import UIKit

class SummaryTableViewController: UITableViewController {
    
    var stockModel: StockModel?
    private var summaryCompany: SummaryCompany?
    private var dictSummary: OrderedDictionary <String, String>?
    
    var networkSummarysManager = NetworkSummaryManager ()
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        tableView.register( UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        
        networkSummarysManager.delegate = self
        if let tickerName = stockModel?.tickerName {
            networkSummarysManager.fetch(forTickerName: tickerName)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let dictCount =  dictSummary?.count else {
            return 0
        }
        return dictCount
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        
        if let dict = dictSummary {
            let line = dict[indexPath.row]
            cell.textLabel?.attributedText = addToTable(title: line.0, text: line.1)
        }
        
        cell.textLabel?.numberOfLines = 50
        cell.textLabel?.textColor = UIColor(named: "TextColor")
        
        return cell
    }
    
    fileprivate func addToTable (title: String, text: String?) -> NSMutableAttributedString {
        let myAttributeHeadLine = [ NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 15.0)! ]
        let myAttributeSummary = [ NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 14.0)! ]
        let myAttrString = NSMutableAttributedString(string: "\(title): ", attributes: myAttributeHeadLine)
        
        myAttrString.append (NSAttributedString(string: text!, attributes: myAttributeSummary))
        
        return myAttrString
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dict = dictSummary else { return }
        let line = dict[indexPath.row]
        guard line.0 == "Website" else { return }
        guard let url = URL(string: line.1) else { return }
        UIApplication.shared.open(url)
    }
}


// MARK: - NetworkSummaryManagerDelegate
extension SummaryTableViewController: NetworkSummaryManagerDelegate {
    func updateSummary(_: NetworkSummaryManager, withSummaryCompany summaryCompany: SummaryCompany) {
        DispatchQueue.main.async {
            self.summaryCompany = summaryCompany
            self.dictSummary = self.fillDict()
            self.tableView.reloadData()
        }
    }
    
    private func fillDict () -> OrderedDictionary <String, String>?{
        var dict = OrderedDictionary <String, String>()
        guard let company = summaryCompany else { return nil}
        
        dict ["Ticker"] = company.symbol
        dict ["Company name"] = company.companyName
        dict ["Exchange"] = company.exchange
        
        if company.industry != "" { dict ["Industry"] = company.industry }
        if company.website != "" { dict ["Website"] = company.website }
        if company.description != "" { dict ["Description"] = company.description }
        if company.CEO != "" { dict ["CEO"] = company.CEO }
        if company.employees != 0 && company.employees != nil { dict ["Number of employees"] = String(company.employees!) }
        if company.address != "" && company.address != nil { dict ["Address"] = company.address }
        if company.state != "" && company.state != nil { dict ["State"] = company.state }
        if company.city != "" && company.city != nil { dict ["City"] = company.city }
        if company.zip != "" && company.zip != nil { dict ["Zip"] = company.zip }
        if company.country != "" && company.country != nil { dict ["Country"] = company.country }
        if company.phone != "" && company.phone != nil { dict ["Phone"] = company.phone }
        
        return dict
    }
}
