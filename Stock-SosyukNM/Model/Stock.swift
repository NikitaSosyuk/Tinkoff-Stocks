//
//  Stock.swift
//  Stock-SosyukNM
//
//  Created by Nikita Sosyuk on 31.01.2021.
//

import Foundation

struct Stock: Codable {
    let symbol: String
    let companyName: String
    let latestPrice: Double
    let change: Double
}
