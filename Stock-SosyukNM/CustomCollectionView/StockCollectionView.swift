//
//  StockCollectionView.swift
//  Stock-SosyukNM
//
//  Created by Nikita Sosyuk on 31.01.2021.
//

import UIKit

class StockCollectionView: UICollectionView {
    
    private var stock: Stock = Stock(symbol: "-", companyName: "-", latestPrice: Double.leastNonzeroMagnitude, change: Double.leastNonzeroMagnitude)
    private let titleData = ["Company name", "Symbol", "Price", "Price change"]
    private let imageSystemNameData = ["building.columns.fill", "doc.plaintext", "dollarsign.square", "arrow.up.arrow.down.square"]
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        
        delegate = self
        dataSource = self
        translatesAutoresizingMaskIntoConstraints = false
        register(StockCollectionViewCell.self, forCellWithReuseIdentifier: StockCollectionViewCell.reuseId)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .systemGray6
        layer.cornerRadius = 20
        
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        contentInset = UIEdgeInsets(top: 0, left: Constants.leftDistance, bottom: 0, right: Constants.rightDistance)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Set all the information in the collection view
    func setStock(stock: Stock) {
        self.stock = stock
        reloadData()
    }
    
    /// Replace all information about stock in collectionView on "-"
    func clearInfo() {
        stock =  Stock(symbol: "-", companyName: "-", latestPrice: Double.leastNonzeroMagnitude, change: Double.leastNonzeroMagnitude)
        reloadData()
    }
    
    // MARK: - Private Func
    
    /// Return property of stock depending on index
    /// - Parameter index: Number of needed property
    /// - Returns: 0 - company name, 1 - stock symbol, 2 - price, 3 - price change
    private func content(index: Int) -> String {
        switch index {
        case 0:
            return stock.companyName
        case 1:
            return stock.symbol
        case 2:
            if stock.latestPrice == Double.leastNonzeroMagnitude {
                return "-"
            }
            return "\(stock.latestPrice)"
        case 3:
            if stock.change == Double.leastNonzeroMagnitude {
                return "-"
            }
            return "\(stock.change)"
        default:
            return "-"
        }
    }
}

// MARK: - UICollectionViewDataSource

extension StockCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: StockCollectionViewCell.reuseId, for: indexPath) as? StockCollectionViewCell else { fatalError("ReuseId error") }
        cell.dropSet()
        let index = indexPath.row
        cell.setData(imageSystemName: imageSystemNameData[index], title: titleData[index], content: content(index: index))
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StockCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.itemWidth, height: frame.height * 0.7)
    }
    
}
