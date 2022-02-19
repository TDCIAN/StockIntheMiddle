//
//  SettingsViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/16.
//

import UIKit
import SnapKit

final class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTitleView()
    }
    
    private func setUpTitleView() {
        let titleView = UIView()
        let label = UILabel()
        label.text = "Settings"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        titleView.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
        }
        navigationItem.titleView = titleView
    }
}
