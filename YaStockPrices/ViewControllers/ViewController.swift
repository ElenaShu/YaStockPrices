//
//  TableViewController.swift
//  YaStockPrices
//
//  Created by Elena Shurygina on 17.03.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var context: NSManagedObjectContext!
    private let searchController = UISearchController(searchResultsController: nil)
   
    private var isFavouriteSelected = false
    
    private var stocks = [StockModel]()
    private var favouriteStocks = [StockModel]()
    private var findedStocks = [StockModel]()
    private var favouriteStocksCD = [FavouriteStock]()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    var networkStocksManager = NetworkStocksManager ()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stockPageButton: UIButton!
    @IBOutlet weak var favouritePageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        customizeButton()
        
        favouriteStocks = stocks.filter({ (stock: StockModel) -> Bool in
            return stock.isFavourite
        })
        networkStocksManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getStartStocks()
    }

    private func setupSearchBar() {
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.searchBar.searchTextField
        
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func customizeButton() {
        stockPageButton.setTitle("Stocks", for: .normal)
        favouritePageButton.setTitle("Favourite", for: .normal)
        setCustomizeSelectedPage (forButton: stockPageButton)
        setCustomizeUnselectedPage (forButton: favouritePageButton)
    }
    
    private func setCustomizeSelectedPage (forButton button: UIButton) {
        button.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
    }
    
    private func setCustomizeUnselectedPage (forButton button: UIButton) {
        button.setTitleColor(UIColor(named: "Lightgray"), for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
    }
    
    @IBAction func updateStocks(_ sender: UIBarButtonItem) {
        if isFavouriteSelected {
            favouriteStocks.forEach { stockModel in
                networkStocksManager.fetchCurrentStock(forRequestType: .update(tickerName: stockModel.tickerName) )
            }
        } else {
            stocks.forEach { stockModel in
                networkStocksManager.fetchCurrentStock(forRequestType: .update(tickerName: stockModel.tickerName) )
            }
        }
    }
    
    @IBAction func selectStockPage(_ sender: UIButton) {
        isFavouriteSelected = false
        navigationItem.title = "Stocks"
        setCustomizeSelectedPage (forButton: stockPageButton)
        setCustomizeUnselectedPage (forButton: favouritePageButton)
        if isFiltering {
            filterContentForSeatchText(searchText: searchController.searchBar.text!)
        }
        tableView.reloadData()
    }
    
    @IBAction func selectFavouritePage(_ sender: UIButton) {
        isFavouriteSelected = true
        navigationItem.title = "Favourite"
        setCustomizeSelectedPage (forButton: favouritePageButton)
        setCustomizeUnselectedPage (forButton: stockPageButton)
        if isFiltering {
            filterContentForSeatchText(searchText: searchController.searchBar.text!)
        }
        tableView.reloadData()
    }
    
    // Core Data
    
    
    private func getStartStocks () {
        let fetchRequest: NSFetchRequest <FavouriteStock> = FavouriteStock.fetchRequest()
        let index = "^DJI"

        do {
            favouriteStocksCD = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print (error.localizedDescription)
        }
        networkStocksManager.fetchCurrentStock( forRequestType: .start(index: index, favouriteStocksCD: favouriteStocksCD) )
    }
    
    private func saveFavouriteStock (withStockModel stockModel: StockModel) {

        guard let entity = NSEntityDescription.entity(forEntityName: "FavouriteStock", in: context) else { return }
        
        let favouriteStock = FavouriteStock (entity: entity, insertInto: context)
        favouriteStock.companyName = stockModel.companyName
        favouriteStock.tickerName = stockModel.tickerName
        
        if stockModel.image != nil {
            let imageData = stockModel.image!.pngData()
            favouriteStock.imageData = imageData
        }
        
        
        do {
            try context.save()
            favouriteStocksCD.append(favouriteStock)
        } catch let error as NSError {
            print (error.localizedDescription)
        }

    }
    
    private func deleteFavouriteStock (withTickerName tickerName: String) {
        let fetchRequest: NSFetchRequest <FavouriteStock> = FavouriteStock.fetchRequest()
        if let objects = try? context.fetch(fetchRequest) {
            guard let index = objects.firstIndex(where: { $0.tickerName == tickerName}) else { return }
            context.delete (objects[index])
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print (error.localizedDescription)
        }
    }
}

// MARK: - Table view data source
extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? findedStocks.count : ( isFavouriteSelected ? favouriteStocks.count : stocks.count )
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let stock = isFiltering ? findedStocks[indexPath.row] : ( isFavouriteSelected ? favouriteStocks[indexPath.row] : stocks[indexPath.row] )
        cell.setInfo(stock: stock)
        cell.delegate = self
        cell.backgroundColor = (indexPath.row + 1) % 2 == 0 ? UIColor(named: "BackgroundColorEvenCell") : UIColor(named: "BackgroundColorCell")
        return cell
    }
    

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isFavouriteSelected == false else {return nil}
        let add = changeFavouriteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [add])
    }
    
    func changeFavouriteAction( at indexPath: IndexPath) -> UIContextualAction {
        if isFiltering {
            let action = UIContextualAction (style: .normal, title: "Change") { (action, view, completion) in
                if self.findedStocks[indexPath.row].isFavourite == false {
                    if let index = self.stocks.firstIndex(where: { $0.tickerName == self.findedStocks[indexPath.row].tickerName}) {
                        self.stocks[index].isFavourite = true
                    }
                    self.findedStocks[indexPath.row].isFavourite = true
                    self.favouriteStocks.append(self.findedStocks[indexPath.row])
                    self.saveFavouriteStock(withStockModel: self.findedStocks[indexPath.row])
                }
                else {
                    if let index = self.stocks.firstIndex(where: { $0.tickerName == self.findedStocks[indexPath.row].tickerName}) {
                        self.stocks[index].isFavourite = false
                    }
                    self.findedStocks[indexPath.row].isFavourite = false
                    if let index: Int = self.favouriteStocks.firstIndex(where: {$0.tickerName == self.findedStocks[indexPath.row].tickerName}) {
                        self.favouriteStocks.remove(at: index)
                    }
                    self.deleteFavouriteStock(withTickerName: self.findedStocks[indexPath.row].tickerName)
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                completion(true)
            }
            action.backgroundColor = self.findedStocks[indexPath.row].isFavourite ? .systemGray : .systemYellow
            action.image = UIImage (systemName: "star.fill")
            
            return action
        }
        else {
            let action = UIContextualAction (style: .normal, title: "Change") { (action, view, completion) in
                if self.stocks[indexPath.row].isFavourite == false {
                    self.stocks[indexPath.row].isFavourite = true
                    self.favouriteStocks.append(self.stocks[indexPath.row])
                    self.saveFavouriteStock(withStockModel: self.stocks[indexPath.row])
                }
                else {
                    self.stocks[indexPath.row].isFavourite = false
                    if let index: Int = self.favouriteStocks.firstIndex(where: {$0.tickerName == self.stocks[indexPath.row].tickerName}) {
                        self.favouriteStocks.remove(at: index)
                    }
                    self.deleteFavouriteStock(withTickerName: self.stocks[indexPath.row].tickerName)
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                completion(true)
            }
            action.backgroundColor = self.stocks[indexPath.row].isFavourite ? .systemGray : .systemYellow
            action.image = UIImage (systemName: "star.fill")
            return action
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isFavouriteSelected == true else {return nil}
        let delete = deleteFavouriteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteFavouriteAction( at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction (style: .destructive, title: "Delete") { (action, view, completion) in
            if self.isFiltering {
                if let index: Int = self.favouriteStocks.firstIndex(where: {$0.tickerName == self.findedStocks[indexPath.row].tickerName}) {
                    self.favouriteStocks.remove(at: index)
                }
                if let index: Int = self.stocks.firstIndex(where: {$0.tickerName == self.findedStocks[indexPath.row].tickerName}) {
                    self.stocks[index].isFavourite = false
                }
                self.deleteFavouriteStock(withTickerName: self.findedStocks[indexPath.row].tickerName)
                self.findedStocks.remove(at: indexPath.row)
            }
            else{
                let removeStock = self.favouriteStocks.remove(at: indexPath.row)
                if let stockCurrentIndex: Int = self.stocks.firstIndex(where: {$0.tickerName == removeStock.tickerName}) {
                    self.stocks[stockCurrentIndex].isFavourite = false
                }
                self.deleteFavouriteStock(withTickerName: removeStock.tickerName)
            }
            self.tableView.reloadData()
            completion(true)
        }
        
        return action
    }
}

// MARK: - Search
extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterContentForSeatchText(searchText: searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        findedStocks = []
        tableView.reloadData()
    }
    
    private func filterContentForSeatchText (searchText: String) {
        if isFavouriteSelected
        {
            findedStocks = favouriteStocks.filter({ $0.tickerName.uppercased().contains(searchText.uppercased()) || $0.companyName.uppercased().contains(searchText.uppercased()) })
        }
        else {
            favouritePageButton.isEnabled = false
            findedStocks = stocks.filter({ $0.tickerName.uppercased().contains(searchText.uppercased()) || $0.companyName.uppercased().contains(searchText.uppercased()) })
            networkStocksManager.fetchCurrentStock(forRequestType: .fragment(fragment: searchText) )
        }
        tableView.reloadData()
    }
    
}

extension ViewController: NetworkStocksManagerDelegate {
    
    func updateInterface(_: NetworkStocksManager, with stockModel: StockModel) {
        DispatchQueue.main.async {
            if self.isFiltering {
                if (!self.stocks.contains(where: { stock in stock.tickerName == stockModel.tickerName } ) ) {
                    self.findedStocks.append(stockModel)
                }
            } else {
                self.stocks.append (stockModel)
            }
            self.tableView.reloadData()
            self.favouritePageButton.isEnabled = true
        }
    }
    
    func updateFavouriteStocks(_: NetworkStocksManager, with stockModel: StockModel) {
        DispatchQueue.main.async {
            self.favouriteStocks.append(stockModel)
            if let indexStock = self.stocks.firstIndex(where: { $0.tickerName == stockModel.tickerName}) {
                self.stocks[indexStock].isFavourite = true
            }
            if let indexFinded = self.findedStocks.firstIndex(where: { $0.tickerName == stockModel.tickerName}) {
                self.findedStocks[indexFinded].isFavourite = true
            }
        }
    }
    
    func notUpdate(_: NetworkStocksManager) {
        DispatchQueue.main.async {
            self.favouritePageButton.isEnabled = true
        }
    }
    
    func updatePrices(_: NetworkStocksManager, with stockModel: StockModel) {
        DispatchQueue.main.async {
            if let indexStock = self.stocks.firstIndex(where: { $0.tickerName == stockModel.tickerName}) {
                self.stocks[indexStock].currentPrice = stockModel.currentPrice
                self.stocks[indexStock].dayDelta = stockModel.dayDelta
            }
            if let indexStock = self.favouriteStocks.firstIndex(where: { $0.tickerName == stockModel.tickerName}) {
                self.favouriteStocks[indexStock].currentPrice = stockModel.currentPrice
                self.favouriteStocks[indexStock].dayDelta = stockModel.dayDelta
            }
            
            self.tableView.reloadData()
        }
    }
}

extension ViewController: TableViewCellDelegate {
    func didTapFavouriteButton(_: TableViewCell, forTickerName tickerName: String) {
        
        if isFiltering {
            guard let indexFinded = findedStocks.firstIndex(where: {$0.tickerName == tickerName}) else {return}
            if findedStocks[indexFinded].isFavourite {
                findedStocks[indexFinded].isFavourite = false
                if let indexFav: Int = self.favouriteStocks.firstIndex(where: {$0.tickerName == tickerName}) {
                    favouriteStocks.remove(at: indexFav)
                }
                if let indexS = stocks.firstIndex(where: {$0.tickerName == tickerName}) {
                    stocks[indexS].isFavourite = false
                }
                deleteFavouriteStock(withTickerName: tickerName)
                tableView.reloadData()
            }
            else {
                findedStocks[indexFinded].isFavourite = true
                favouriteStocks.append(findedStocks[indexFinded])
                saveFavouriteStock(withStockModel: findedStocks[indexFinded])
                if let indexS = stocks.firstIndex(where: {$0.tickerName == tickerName}) {
                    stocks[indexS].isFavourite = true
                }
                tableView.reloadRows(at: [IndexPath(row: indexFinded, section: 0)], with: .automatic)
            }
        }
        else {
            if isFavouriteSelected {
                guard let index = favouriteStocks.firstIndex(where: {$0.tickerName == tickerName}) else {return}
                favouriteStocks.remove(at: index)
                if let stockCurrentIndex: Int = stocks.firstIndex(where: {$0.tickerName == tickerName}) {
                    self.stocks[stockCurrentIndex].isFavourite = false
                }
                deleteFavouriteStock(withTickerName: tickerName)
                tableView.reloadData()
            }
            else{
                guard let indexStock = stocks.firstIndex(where: {$0.tickerName == tickerName}) else {return}
                if stocks[indexStock].isFavourite == true {
                    stocks[indexStock].isFavourite = false
                    if let stockFavouriteCurrentIndex: Int = self.favouriteStocks.firstIndex(where: {$0.tickerName == tickerName}) {
                        favouriteStocks.remove(at: stockFavouriteCurrentIndex)
                    }
                    deleteFavouriteStock(withTickerName: tickerName)
                }
                else {
                    stocks[indexStock].isFavourite = true
                    favouriteStocks.append(stocks[indexStock])
                    saveFavouriteStock(withStockModel: stocks[indexStock])
                }
                tableView.reloadRows(at: [IndexPath(row: indexStock, section: 0)], with: .automatic)
            }
            
        }
    }
    
}

