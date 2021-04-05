//
//  NewsView.swift
//  YaStockPrices
//
//  Created by Elenasshu on 03.04.2021.
//

import UIKit

class NewsViewController: UIViewController {

    var stockModel: StockModel?
    private var arrayNewsModel = [NewsModel]()
    
    var networkNewsManager = NetworkNewsManager ()
    
    @IBOutlet weak var newsTableView: UITableView!

    override func viewDidLoad () {
        super.viewDidLoad()
        
        newsTableView.register(UINib(nibName: String(describing: NewsTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: NewsTableViewCell.self))
        
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        if let tickerName = stockModel?.tickerName {
            networkNewsManager.fetch(forTickerName: tickerName)
        }
        networkNewsManager.delegate = self
    }
    
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNewsModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTableView.dequeueReusableCell(withIdentifier: String(describing: NewsTableViewCell.self), for: indexPath) as! NewsTableViewCell
        cell.setInfo(news: arrayNewsModel[indexPath.row])
        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        416
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = arrayNewsModel[indexPath.row].url 
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

extension NewsViewController: NetworkNewsManagerDelegate {
    
    func updateNews(_: NetworkNewsManager, withArrayNewsModel arrayNewsModel: Array<NewsModel>) {
        DispatchQueue.main.async {
            self.arrayNewsModel = arrayNewsModel
            self.newsTableView.reloadData()
        }
    }
}
