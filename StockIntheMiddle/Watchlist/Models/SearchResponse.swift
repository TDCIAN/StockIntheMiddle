//
//  SearchResponse.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/08.
//

import Foundation

struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
