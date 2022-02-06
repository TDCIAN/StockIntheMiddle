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
        
    }
    
    private init() {}
    
    // MARK: - Public
    var watchlist: [String] {
        return []
    }
    
    public func addToWatchList() {
        
    }
    
    public func removeFromWatchList() {
        
    }
    
    // MARK: - Private
    private var hasOnboarded: Bool {
        return false
    }
}
