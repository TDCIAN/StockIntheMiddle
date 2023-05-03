//
//  DateFormatter+.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2023/05/03.
//

import Foundation

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let prettyDateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
