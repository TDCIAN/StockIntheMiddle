//
//  CalcSearchResults.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/24.
//

import Foundation

struct CalcSearchResults: Decodable {

    let items: [CalcSearchResult]

    enum CodingKeys: String, CodingKey {
        case items = "bestMatches"
    }
}

struct CalcSearchResult: Decodable {
    let symbol: String
    let name: String
    let type: String
    let currency: String

    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case currency = "8. currency"
    }
}
