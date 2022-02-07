//
//  NewsStory.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/08.
//

import Foundation

struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline:String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
