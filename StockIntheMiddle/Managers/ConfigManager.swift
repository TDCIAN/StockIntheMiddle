//
//  ConfigManager.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/20.
//

import Foundation

class Constants {
    static let IS_DARK_MODE = "IS_DARK_MODE"
    static let UNITS_TYPE = "UNITS_TYPE"
}

class ConfigManager {
    static let getInstance = ConfigManager()
    
    var isDarkMode: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.IS_DARK_MODE)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Constants.IS_DARK_MODE)
        }
    }
    
    var unitsType: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UNITS_TYPE)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Constants.UNITS_TYPE)
        }
    }
}
