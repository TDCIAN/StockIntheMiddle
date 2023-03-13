//
//  Extensions.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import Foundation
import UIKit

// MARK: - Notification
extension Notification.Name {
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}

// MARK: - NumberFormatter
extension NumberFormatter {

    static let percentFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let numberFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// MARK: - ImageView
extension UIImageView {

    func setImage(with url: URL?) {
        guard let url = url else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}

// MARK: - String
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

// MARK: - DateFormatter
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

// MARK: - Add Subview
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

// MARK: - Framing
extension UIView {
    var width: CGFloat {
        frame.size.width
    }

    var height: CGFloat {
        frame.size.height
    }

    var left: CGFloat {
        frame.origin.x
    }

    var right: CGFloat {
        left + width
    }

    var top: CGFloat {
        frame.origin.y
    }

    var bottom: CGFloat {
        top + height
    }
}

// MARK: - CandleStick Sorting
extension Array where Element == CandleStick {
    func getPercentage() -> Double {
        let latestDate = self[0].date
        guard let latestClose = self.first?.close,
              let priorClose = self.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else {
                  return 0
              }
        let diff = 1 - (priorClose / latestClose)
        return diff
    }
}

extension UIColor {

    static let themeRedShade = UIColor("FAE2E1")
    static let themeGreenShade = UIColor("B0F1DD")

    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.removeFirst()
        }

        if (cString.count) != 6 {
            self.init("ff0000") // return red color for wrong hex input
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }

}

extension Double {
    var stringValue: String {
        return String(describing: self)
    }

    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }

    var currencyFormat: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .init(identifier: "en_US")
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }

    var percentageFormat: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }

    func toCurrencyFormat(hasDollarSymbol: Bool = true, hasDecimalPlaces: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .init(identifier: "en_US")
        if hasDollarSymbol == false {
            formatter.currencySymbol = ""
        }
        if hasDecimalPlaces == false {
            formatter.maximumFractionDigits = 0
        }
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
}

extension Int {
    var floatValue: Float {
        return Float(self)
    }

    var doubleValue: Double {
        return Double(self)
    }
}

extension Date {
    var MMYYFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = .autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
}

extension UITextField {
    func addDoneButton() {
        let screenWidth = UIScreen.main.bounds.width
        let doneToolBar: UIToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
        doneToolBar.barStyle = .default
        let flexBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        let items = [flexBarButtonItem, doneBarButtonItem]
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        inputAccessoryView = doneToolBar
    }

    @objc private func dismissKeyboard() {
        resignFirstResponder()
    }
}
