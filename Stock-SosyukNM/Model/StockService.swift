//
//  StockService.swift
//  Stock-SosyukNM
//
//  Created by Nikita Sosyuk on 31.01.2021.
//

import UIKit

class StockService {
    private let responseQueue: DispatchQueue
    private let timeoutInterval: TimeInterval = 10
    private let token = "pk_e933760a98264d238ebbab3652a3094e"
    
    init(responseQueue: DispatchQueue) {
        self.responseQueue = responseQueue
    }
    
    /// Load Stock by stock symbol (use iexcloud api)
    /// - Parameters:
    ///   - symbol: Symbol of stock
    ///   - completion: Processing the result (list of Company or error) in responseQueue
    func loadStock(for symbol: String, _ completion: @escaping (Result<Stock, StockServiceError>) -> Void) {
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)") else { return }
        let urlRequest = makeUrlRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            let result: Result<Stock, StockServiceError>
            defer {
                self?.responseQueue.async {
                    completion(result)
                }
            }
            if let error = error {
                return result = .failure(.system(error))
            }
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                return result = .failure(.httpResponseError)
            }
            guard let data = data else {
                return result = .failure(.noData)
            }
            do {
                let response = try JSONDecoder().decode(Stock.self, from: data)
                result = .success(response)
            } catch {
                return result = .failure(.parsing(error))
            }
        }
        dataTask.resume()
    }
    
    /// Load list of Company (mostactive in iexcloud api)
    /// - Parameters:
    ///   - completion: Processing the result (list of Company or error) in responseQueue
    func loadStockList(_ completion: @escaping (Result<[Company], StockServiceError>) -> Void) {
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/market/list/mostactive?token=\(token)") else { return }
        let urlRequest = makeUrlRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            let result: Result<[Company], StockServiceError>
            defer {
                self?.responseQueue.async {
                    completion(result)
                }
            }
            if let error = error {
                return result = .failure(.system(error))
            }
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                return result = .failure(.httpResponseError)
            }
            guard let data = data else {
                return result = .failure(.noData)
            }
            do {
                let response = try JSONDecoder().decode([Company].self, from: data)
                result = .success(response)
            } catch {
                return result = .failure(.parsing(error))
            }
        }
        dataTask.resume()
    }
    
    /// Load image of company
    /// - Parameters:
    ///   - symbol: Symbol of stock
    ///   - completion: Processing the result (image or error) in responseQueue
    func loadImageOfCompany(for symbol: String, _ completion: @escaping (Result<UIImage, StockServiceError>) -> Void) {
        guard let url = URL(string: "https://storage.googleapis.com/iexcloud-hl37opg/api/logos/\(symbol).png") else { return }
        let urlRequest = makeUrlRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            let result: Result<UIImage, StockServiceError>
            defer {
                self?.responseQueue.async {
                    completion(result)
                }
            }
            if let error = error {
                return result = .failure(.system(error))
            }
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                return result = .failure(.httpResponseError)
            }
            guard let data = data else {
                return result = .failure(.noData)
            }
            guard let response = UIImage(data: data) else {
                result = .failure(.imageCast)
                return
            }
            result = .success(response)
        }
        dataTask.resume()
    }
    
    /// Make URLRequest from URL with GET method, content type = text/json, timeout interval
    private func makeUrlRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("text/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = timeoutInterval
        return urlRequest
    }

}
