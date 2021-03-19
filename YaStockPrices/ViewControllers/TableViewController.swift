//
//  TableViewController.swift
//  YaStockPrices
//
//  Created by Elenasshu on 17.03.2021.
//

import UIKit

class TableViewController: UITableViewController {

    let searchController = UISearchController(searchResultsController: nil)
   
   // var stocks = [StockModel]()
    
    var stocks = [StockModel(stockData: StockData(companyName: "Yandex, LLC", tickerName: "YNDX",                    currentPrice: 4754.6, currency: "₽", dayDelta: DayDelta(currency: 55, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL1",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL2",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL3",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL4",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL5",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL6",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL7",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL8",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL9",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL10",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL11",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL12",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL13",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!,
                  StockModel(stockData: StockData(companyName: "Apple Inc", tickerName: "AAPL14",
                currentPrice: 131.93, currency: "$", dayDelta: DayDelta(currency: 0.12, percentage: 1.15)))!
                ]
    
    var isFavouriteSelected = false
    
    var favouriteStocks = [StockModel]()
    @IBOutlet weak var stockPage: UIButton!
    @IBOutlet weak var favouritePage: UIButton!
    
    var networkStocksManager = NetworkStocksManager ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        customizeButton()
        favouriteStocks = stocks.filter({ (stock: StockModel) -> Bool in
            return stock.isFavourite
        })
        
        var tickerName = ""
        networkStocksManager.delegate = self
        networkStocksManager.fetchCurrentStock(forRequestType: .tickerName (tickerName: tickerName))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.delegate = self
    }
    
    private func customizeButton() {
        stockPage.setTitle("Stocks", for: .normal)
       // stockPage.backgroundColor = .red
        //stockPage.setTitleColor(UIColor(named: "gray"), for: .normal)
        
        favouritePage.setTitle("Favourite", for: .normal)
     //   favouritePage.setTitleColor(UIColor(named: "lightgray"), for: .normal)
    }
    
    @IBAction func selectStockPage(_ sender: UIButton) {
        isFavouriteSelected = false
        tableView.reloadData()
    }
    
    @IBAction func selectFavouritePage(_ sender: UIButton) {
        isFavouriteSelected = true
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFavouriteSelected == false {
            return stocks.count
        }
        else {
            return favouriteStocks.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        var stock: StockModel
        if isFavouriteSelected == false {
            stock = stocks[indexPath.row]
        }
        else {
            stock = favouriteStocks[indexPath.row]
        }
        cell.setInfo(stock: stock)
        cell.delegate = self
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isFavouriteSelected == false else {return nil}
        let add = changeFavouriteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [add])
    }
    
    func changeFavouriteAction( at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction (style: .normal, title: "Change") { (action, view, completion) in
            if self.stocks[indexPath.row].isFavourite == false {
                self.stocks[indexPath.row].isFavourite = true
                self.favouriteStocks.append(self.stocks[indexPath.row])
            }
            else {
                self.stocks[indexPath.row].isFavourite = false
                if let stockFavouriteCurrentIndex: Int = self.favouriteStocks.firstIndex(where: {$0.tickerName == self.stocks[indexPath.row].tickerName}) {
                    self.favouriteStocks.remove(at: stockFavouriteCurrentIndex)
                }
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        if self.stocks[indexPath.row].isFavourite == true {
            action.backgroundColor = .systemGray
        }
        else {
            action.backgroundColor = .systemYellow
        }
        action.image = UIImage (systemName: "star.fill")
        
        return action
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isFavouriteSelected == true else {return nil}
        let delete = deleteFavouriteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteFavouriteAction( at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction (style: .destructive, title: "Delete") { (action, view, completion) in
            let removeStock = self.favouriteStocks.remove(at: indexPath.row)
            if let stockCurrentIndex: Int = self.stocks.firstIndex(where: {$0.tickerName == removeStock.tickerName}) {
                self.stocks[stockCurrentIndex].isFavourite = false
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        return action
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TableViewController: UISearchBarDelegate {
    
}

extension TableViewController: NetworkStocksManagerDelegate {
    func updateInterface(_: NetworkStocksManager, with stockModel: StockModel) {
        DispatchQueue.main.async { // Проверить надо или нет, если не будет падать то не надо
            self.stocks.append (stockModel)
            self.tableView.reloadData()
        }
    }
    
    
}

extension TableViewController: TableViewCellDelegate {
    func didTapFavouriteButton(_: TableViewCell, forTickerName tickerName: String) {
        
        if isFavouriteSelected == false {
            guard let indexStock = stocks.firstIndex(where: {$0.tickerName == tickerName}) else {return}
            if stocks[indexStock].isFavourite == true {
                stocks[indexStock].isFavourite = false
                if let stockFavouriteCurrentIndex: Int = self.favouriteStocks.firstIndex(where: {$0.tickerName == tickerName}) {
                    favouriteStocks.remove(at: stockFavouriteCurrentIndex)
                }
            }
            else {
                stocks[indexStock].isFavourite = true
                favouriteStocks.append(stocks[indexStock])
            }
            tableView.reloadRows(at: [IndexPath(row: indexStock, section: 0)], with: .automatic)
        }
        else {
            guard let indexFavouriteStock = favouriteStocks.firstIndex(where: {$0.tickerName == tickerName}) else {return}
            favouriteStocks.remove(at: indexFavouriteStock)
            if let stockCurrentIndex: Int = stocks.firstIndex(where: {$0.tickerName == tickerName}) {
                self.stocks[stockCurrentIndex].isFavourite = false
            }
            tableView.reloadData()
        }
    }
    
    
}

