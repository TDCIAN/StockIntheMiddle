//
//  Date+.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2023/05/03.
//

import Foundation

extension Date {
    var MMYYFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = .autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
}
