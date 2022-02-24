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
    
//    @IBOutlet weak var assetNameLabel: UILabel!
//    @IBOutlet weak var assetSymbolLabel: UILabel!
//    @IBOutlet weak var assetTypeLabel: UILabel!
    
    private let assetNameLabel: UILabel = {
       let label = UILabel()
        return label
    }()
    private let assetSymbolLabel: UILabel = {
       let label = UILabel()
        return label
    }()
    private let assetTypeLabel: UILabel = {
       let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(assetNameLabel, assetSymbolLabel, assetTypeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        assetSymbolLabel.snp.makeConstraints {
            $0.leading.equalTo(15)
            $0.bottom.equalToSuperview().offset(-7)
        }
        assetTypeLabel.snp.makeConstraints {
            $0.leading.equalTo(15)
            $0.top.equalToSuperview().offset(7)
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
