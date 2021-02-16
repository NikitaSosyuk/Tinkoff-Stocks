//
//  DownloadErrorType.swift
//  Stock-SosyukNM
//
//  Created by Nikita Sosyuk on 31.01.2021.
//

import Foundation

enum DownloadTypeError: String {
    case pickerViewData = "ErrorCode #1 - download data for picker"
    case imageViewData = "ErrorCode #2 - download data for image of company"
    case stockData = "ErrorCode #3 - download data for stockInfo"
}
