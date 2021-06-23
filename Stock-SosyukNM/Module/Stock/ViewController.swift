//
//  ViewController.swift
//  Stock-SosyukNM
//
//  Created by Nikita Sosyuk on 31.01.2021.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        return indicator
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.text = "Stock"
        return label
    }()
    
    private let companyPickerView = UIPickerView()
    private let companyLogoImageView = UIImageView()
    private var stockCollectionView = StockCollectionView()
    
    // MARK: - Properties
    var stockService: StockServiceProtocol?
    private var companies: [Company] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        makeLayout()
        
        companyPickerView.dataSource = self
        companyPickerView.delegate = self

        requestStockList()
    }

    // MARK: - Private func
    private func addSubviews() {
        view.addSubview(stockCollectionView)
        view.addSubview(activityIndicator)
        view.addSubview(statusLabel)
        view.addSubview(companyLogoImageView)
        view.addSubview(companyPickerView)
    }

    private func makeLayout() {
        stockCollectionView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        companyLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        companyPickerView.translatesAutoresizingMaskIntoConstraints = false
    
        companyLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        companyLogoImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15).isActive = true
        companyLogoImageView.widthAnchor.constraint(equalTo: companyLogoImageView.heightAnchor).isActive = true
        companyLogoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        companyLogoImageView.layer.cornerRadius = 10
        companyLogoImageView.contentMode = .scaleAspectFit
        
        statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        statusLabel.topAnchor.constraint(equalTo: companyLogoImageView.bottomAnchor, constant: 15).isActive = true
    
        companyPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        companyPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        companyPickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        companyPickerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: companyPickerView.topAnchor).isActive = true
        
        stockCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stockCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stockCollectionView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20).isActive = true
        stockCollectionView.bottomAnchor.constraint(equalTo: activityIndicator.topAnchor, constant: -5).isActive = true
    }

    private func requestStockList() {
        startDownload()
        stockService?.loadStockList() { [weak self] result in
            switch result {
            case .success(let companies):
                self?.saveStockList(companies: companies)
            case .failure(let error):
                print(error)
                self?.errorDownloadAlert(typeError: .pickerViewData, for: nil)
            }
        }
    }

    private func saveStockList(companies: [Company]) {
        managingIndecator(status: false)
        self.companies = companies
        companyPickerView.reloadAllComponents()
        if let symbol = companies.first?.symbol {
            requestStockUpdate(for: symbol)
        }
    }

    private func requestStockUpdate(for symbol: String) {
        startDownload()
        stockService?.loadStock(for: symbol) { [weak self] result in
            switch result {
            case .success(let stock):
                self?.statusLabel.text = "Stock info:"
                self?.managingIndecator(status: false)
                self?.stockCollectionView.setStock(stock: stock)
                break
            case .failure(_):
                self?.errorDownloadAlert(typeError: .stockData, for: symbol)
            }
        }
        stockService?.loadImageOfCompany(for: symbol) { [weak self] result in
            switch result {
            case .success(let image):
                self?.companyLogoImageView.image = image
            case .failure(_):
                self?.errorDownloadAlert(typeError: .imageViewData, for: symbol)
            }
        }
    }

    private func managingIndecator(status: Bool) {
        if status {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

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


