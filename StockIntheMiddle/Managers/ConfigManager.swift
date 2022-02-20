//
//  ConfigManager.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/20.
//

import Foundation

class Constants {
    static let IS_DARK_MODE = "IS_DARK_MODE"
    static let CHART_PERIOD = "CHART_PERIOD"
}

class ConfigManager {
    static let shared = ConfigManager()
    
    var isDarkMode: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.IS_DARK_MODE)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Constants.IS_DARK_MODE)
        }
    }
    
    var chartPeriod: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.CHART_PERIOD)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Constants.CHART_PERIOD)
        }
    }
    
    var numberOfDays: TimeInterval {
        var numberOfDays: TimeInterval = 1
        if chartPeriod == 0 {
            numberOfDays = 1
        } else if chartPeriod == 1 {
            numberOfDays = 7
        } else if chartPeriod == 2 {
            numberOfDays = 30
        } else if chartPeriod == 3 {
            numberOfDays = 365
        }
        return numberOfDays
    }
}
