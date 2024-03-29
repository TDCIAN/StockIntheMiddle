//
//  PersistenceManager.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import Foundation

final class PersistenceManager {

    static let shared = PersistenceManager()

    private let userDefaults: UserDefaults = .standard

    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchListKey = "watchlist"
    }

    private init() {}

    // MARK: - Public
    var watchlist: [String] {
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchListKey) ?? []
    }

    public func watchlistContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }

    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchListKey)
        userDefaults.set(companyName, forKey: symbol)

        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }

    public func removeFromWatchList(symbol: String) {
        var newList = [String]()
        userDefaults.set(nil, forKey: symbol)
        for item in watchlist where item != symbol {
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchListKey)
    }

    // MARK: - Private
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }

    private func setUpDefaults() {
        let map: [String: String] = [
            "SPY": "SPDR S&P 500 ETF TRUST",
            "QQQ": "INVESCO QQQ TRUST SERIES 1",
            "DIA": "SPDR DJIA TRUST",
            "VIXY": "PROSHARES VIX MID-TERM FUT",
            "GLD": "SPDR GOLD SHARES"
        ]

        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchListKey)

        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
