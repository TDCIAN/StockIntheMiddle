//
//  SearchTableViewCell.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/24.
//

import UIKit
import SnapKit

final class SearchTableViewCell: UITableViewCell {

    static let identifier = "SearchTableViewCell"
    static let preferredHeight: CGFloat = 88

    private let assetSymbolLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()
    private let assetTypeLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    private let assetNameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(assetSymbolLabel, assetTypeLabel, assetNameLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        assetSymbolLabel.snp.makeConstraints {
            $0.leading.equalTo(15)
            $0.bottom.equalTo(contentView.snp.centerY).offset(-3)
        }
        assetTypeLabel.snp.makeConstraints {
            $0.leading.equalTo(15)
            $0.top.equalTo(contentView.snp.centerY).offset(7.5)
        }
        assetNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
            $0.width.lessThanOrEqualTo(contentView.frame.width * 0.45)
        }
    }

    func configure(with searchResult: CalcSearchResult) {
        assetNameLabel.text = searchResult.name
        assetSymbolLabel.text = searchResult.symbol
        assetTypeLabel.text = searchResult.type
            .appending(" ")
            .appending(searchResult.currency)
    }
}
