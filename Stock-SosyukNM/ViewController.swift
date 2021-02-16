//
//  ViewController.swift
//  Stock-SosyukNM
//
//  Created by Nikita Sosyuk on 31.01.2021.
//
// Использовал свое решение задачи и UI (сказали, что можно).  Пользовательский интерфейс постарался сделать в стиле приложений Тинькофф. Не знаю, как правильно проверять работу ошибок с загрузкой данных на симуляторе, я проверял на своем телефоне - должно работать корректно отображение alert'a. Задание интересное, мне понравилось)) 

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var companyLogoImageView: UIImageView!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    private var stockCollectionView = StockCollectionView()
    
    private let stockService = StockService(responseQueue: .main)
    private var companies: [Company] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stockCollectionView)
        stockCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stockCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stockCollectionView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20).isActive = true
        stockCollectionView.bottomAnchor.constraint(equalTo: activityIndicator.topAnchor, constant: -5).isActive = true
        
        companyLogoImageView.layer.cornerRadius = 10
        
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        requestStockList()
    }
    
    // MARK: - PrivateFunc
    
    /// Download and save list of stocks for pickerView
    private func requestStockList() {
        startDownload()
        stockService.loadStockList() { [weak self] result in
            switch result {
            case .success(let companies):
                self?.saveStockList(companies: companies)
            case .failure(let error):
                print(error)
                self?.errorDownloadAlert(typeError: .pickerViewData, for: nil)
            }
        }
    }
    
    /// Save list of stocks for pickerView, stop animating indecator
    private func saveStockList(companies: [Company]) {
        managingIndecator(status: false)
        self.companies = companies
        companyPickerView.reloadAllComponents()
        if let symbol = companies.first?.symbol {
            requestStockUpdate(for: symbol)
        }
    }
    
    /// Update stock's information and image
    /// - Parameter symbol: Stock symbol of company
    private func requestStockUpdate(for symbol: String) {
        startDownload()
        stockService.loadStock(for: symbol) { [weak self] result in
            switch result {
            case .success(let stock):
                self?.statusLabel.text = "Stock info:"
                self?.managingIndecator(status: false)
                self?.stockCollectionView.setStock(stock: stock)
                break
            case .failure(_):
                //.failure - должна была передоваться еще дополнительная информации о ошибке, но обработать данную информацию не успел
                self?.errorDownloadAlert(typeError: .stockData, for: symbol)
            }
        }
        stockService.loadImageOfCompany(for: symbol) { [weak self] result in
            switch result {
            case .success(let image):
                self?.companyLogoImageView.image = image
            case .failure(_):
                self?.errorDownloadAlert(typeError: .imageViewData, for: symbol)
            }
        }
    }
    
    /// Activating or deactivating the indicator
    /// - Parameter status: True - active, False - inactive
    private func managingIndecator(status: Bool) {
        if status {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    /// Creating and showing download error alert
    /// - Parameter typeError: Type of download error
    /// - Parameter symbol: Symbol for reload stock data or image of company
    private func errorDownloadAlert(typeError: DownloadTypeError, for symbol: String?) {
        let alert = UIAlertController(title: "Unable to Download", message: "Please try again late \n \(typeError.rawValue)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertAction.Style.default) { [weak self] _ in
            switch typeError {
            case .pickerViewData:
                self?.requestStockList()
            case .stockData, .imageViewData:
                if let symbol = symbol {
                    self?.requestStockUpdate(for: symbol)
                }
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Clear information about stock in stockCollectionView, start animating indecator, clear companyLogoImageView, replace text of statusLabel
    private func startDownload() {
        stockCollectionView.clearInfo()
        managingIndecator(status: true)
        companyLogoImageView.image = UIImage()
        statusLabel.text = "Loading..."
    }
}


// MARK: - UIPickerViewDataSource

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.count
    }
}

// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return companies[row].companyName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestStockUpdate(for: companies[row].symbol)
    }
}


