//
//  StockServiceError.swift
//  Stock-SosyukNM
//
//  Created by Nikita Sosyuk on 31.01.2021.
//

import Foundation

enum StockServiceError: Error {
    case system(Error)
    case parsing(Error)
    case httpResponseError
    case noData
    case urlCreation
    case imageCast
}
