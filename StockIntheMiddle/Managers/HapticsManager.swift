//
//  HapticsManager.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import Foundation
import UIKit

final class HapticsManager {

    static let shared = HapticsManager()

    private init() {}

    // MARK: - Public
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
