//
//  UIViewController+.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2023/05/03.
//

import UIKit

extension UIViewController {
    func configNavTitleView(title: String) -> UIView {
        let titleView = UIView()
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = title
            label.font = .systemFont(ofSize: 28, weight: .semibold)
            return label
        }()
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
        }
        return titleView
    }
}
