//
//  StockCollectionViewCell.swift
//  Stock-SosyukNM
//
//  Created by Nikita Sosyuk on 31.01.2021.
//

import UIKit

class StockCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "StockCollectionViewCell"
    
    private let largeContentLenght = 28
    private let mediumContentLenght = 18
    
    // UI
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 3
        return label
    }()
    
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(contentLabel)
        
        backgroundColor = .systemBackground
        
        // imageView constraints
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/4).isActive = true
        
        // titleLabel constraints
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/7).isActive = true
        
        // contentLabel constraints
        contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 15
        self.layer.shadowRadius = 9
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 8)
        
        self.clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Fill UI with stock's data
    /// - Parameters:
    ///   - imageSystemName: System name of image
    ///   - title: Title for cell
    ///   - content: May be company name, price, price change, symbol
    func setData(imageSystemName: String, title: String, content: String) {
        imageView.image = UIImage(systemName: imageSystemName)
        titleLabel.text = title
        contentLabel.text = content
        if title == "Price change" {
            var change = content
            guard let double = Double(content) else {
                contentLabel.text = change
                return
            }
            if double < 0 {
                contentLabel.textColor = .red
                change += " 📉"
            }
            if double > 0 {
                contentLabel.textColor = .green
                change += " 📈"
            }
            contentLabel.text = change
        }
        if title == "Company name" {
            if content.count > largeContentLenght {
                contentLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            } else {
                if content.count > mediumContentLenght {
                    contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                } else {
                    contentLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                }
            }
        }
    }
    
    /// Return all UI to the initial state
    func dropSet() {
        contentLabel.textColor = .label
        contentLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
    }
}
