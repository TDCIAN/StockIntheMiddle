//
//  String+.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2023/05/03.
//

import Foundation

extension String {

    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.newsDateFormatter.string(from: date)
    }

    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }

    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    func addBrackets() -> String {
        return "(\(self))"
    }

    func prefix(withText text: String) -> String {
        return text + self
    }

    func toDouble() -> Double? {
        return Double(self)
    }
}
