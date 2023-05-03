//
//  Array+.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2023/05/03.
//

import Foundation

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
