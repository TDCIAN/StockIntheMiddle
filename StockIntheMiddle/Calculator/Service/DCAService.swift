//
//  DCAService.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/24.
//

import Foundation

struct DCAService {
    func calculate(asset: Asset, initialInvestmentAmount: Double, monthlyDollorCostAverageAmount: Double, initialDateOfInvestmentIndex: Int) -> DCAResult {

        let investmentAmount = getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount,
                                                   monthlyDollorCostAverageAmount: monthlyDollorCostAverageAmount,
                                                   initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)

        let latestSharePrice = getLatestSharePrice(asset: asset)

        let numberOfShares = getNumberOfShares(asset: asset,
                                               initialInvestmentAmount: initialInvestmentAmount,
                                               monthlyDollarCostAveragingAmount: monthlyDollorCostAverageAmount,
                                               initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)

        let currentValue = getCurrentValue(numberOfShares: numberOfShares, latestSharePrice: latestSharePrice)

        let isProfitable = currentValue > investmentAmount

        let gain = currentValue - investmentAmount

        /*
         example
         investmentAmount: $10,000
         (1)
         currentValue: $12,000
         gain = +$2000
         yield = $2000 / $10,000 = 20%
         (2)
         currentValue: $7,000
         gain: -$3,000
         yield: -$3,000 / $10,000 = -30%
         */

        let yield = gain / investmentAmount

        let annualReturn = getAnnualReturn(currentValue: currentValue,
                                           investmentAmount: investmentAmount,
                                           initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)

        return .init(currentValue: currentValue,
                     investmentAmount: investmentAmount,
                     gain: gain,
                     yield: yield,
                     annualReturn: annualReturn,
                     isProfitable: isProfitable)

        // currentValue = numberOfShares (initial + DCA) * latest share price
    }

    func getInvestmentAmount(initialInvestmentAmount: Double,
                                     monthlyDollorCostAverageAmount: Double,
                                     initialDateOfInvestmentIndex: Int) -> Double {
        var totalAmount = Double()
        totalAmount += initialInvestmentAmount
        let dollarCostAveragingAmounts = initialDateOfInvestmentIndex.doubleValue * monthlyDollorCostAverageAmount
        totalAmount += dollarCostAveragingAmounts
        return totalAmount
    }

    private func getAnnualReturn(currentValue: Double, investmentAmount: Double, initialDateOfInvestmentIndex: Int) -> Double {
        let rate = currentValue / investmentAmount
        let years = (initialDateOfInvestmentIndex.doubleValue + 1) / 12
        let result = pow(rate, (1 / years)) - 1
        return result
    }

    private func getCurrentValue(numberOfShares: Double, latestSharePrice: Double) -> Double {
        return numberOfShares * latestSharePrice
    }

    private func getLatestSharePrice(asset: Asset) -> Double {
        return asset.timeSeriesMonthlyAdjusted.getMonthInfos().first?.adjustedClose ?? 0
    }

    private func getNumberOfShares(asset: Asset,
                                   initialInvestmentAmount: Double,
                                   monthlyDollarCostAveragingAmount: Double,
                                   initialDateOfInvestmentIndex: Int) -> Double {

        var totalShares = Double()

        let initialInvestmentOpenPrice = asset.timeSeriesMonthlyAdjusted.getMonthInfos()[initialDateOfInvestmentIndex].adjustedOpen
        let initialInvestmentShares = initialInvestmentAmount / initialInvestmentOpenPrice
        totalShares += initialInvestmentShares
        asset.timeSeriesMonthlyAdjusted.getMonthInfos().prefix(initialDateOfInvestmentIndex).forEach { monthInfo in
            let dcaInvestmentShares = monthlyDollarCostAveragingAmount / monthInfo.adjustedOpen

            totalShares += dcaInvestmentShares
        }
        return totalShares
    }
}

struct DCAResult {
    let currentValue: Double
    let investmentAmount: Double
    let gain: Double
    let yield: Double
    let annualReturn: Double
    let isProfitable: Bool
}
