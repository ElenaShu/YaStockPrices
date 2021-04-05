//
//  WebSocketPriceManager.swift
//  YaStockPrices
//
//  Created by Elenasshu on 31.03.2021.
//

import Foundation

class WebSocketPriceManager {
    
    public static let shared = WebSocketPriceManager() // создаем Синглтон
    private init(){}
    
    var arraySubscribe = [String]()
    var arrayWebSocketUpdates: [WebSocketUpdates] = []
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=\(apiKeyFinnhub)")!)
    
    
    public func connectToWebSocket() {
        webSocketTask.resume()
    }
    
    public func subscribe(forTickerName tickerName: String) {
        guard arraySubscribe.count <= 50 else {
            print ("You cannot subscribe to more than 50 tickers")
            return
        }
        let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(tickerName)\"}")
        arraySubscribe.append (tickerName)
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    public func subscribeArray(forArrayTickerNames arrayTickerName: Array<String>) {
        arraySubscribe.forEach { tickerName in
            if !arrayTickerName.contains(tickerName) {
                unSubscribe(forTickerName: tickerName)
            }
        }
        arrayTickerName.forEach { tickerName in
            if !arraySubscribe.contains(tickerName) {
                subscribe(forTickerName: tickerName)
            }
        }
    }
    
    public func unSubscribe(forTickerName tickerName: String) {
        let message = URLSessionWebSocketTask.Message.string("{\"type\":\"unsubscribe\",\"symbol\":\"\(tickerName)\"}")
        
        if let index = arraySubscribe.firstIndex(where: {$0 == tickerName}) {
            arraySubscribe.remove(at: index)
        }
        
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    
    public func receiveData(completion: @escaping ([WebSocketUpdates]?) -> Void) {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    let dataOpt: Data? = text.data(using: .utf8)
                    guard let data = dataOpt else { return }
                    guard let srvData = self.parseJSON(withData: data) else { return }
                    self.arrayWebSocketUpdates = srvData 
                    
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    debugPrint("Unknown message")
                }
            }
        }
        completion(self.arrayWebSocketUpdates)
    }
    
    fileprivate func parseJSON (withData data: Data) -> [WebSocketUpdates]? {
        let decoder = JSONDecoder()
        do {
            let webSocketData = try decoder.decode (WebSocketData.self, from: data)
            return webSocketData.data
        } catch let error as NSError {
            print (error)
        }
        return nil
    }
}
