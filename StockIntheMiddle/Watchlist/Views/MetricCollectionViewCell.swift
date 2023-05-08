//
//  MetricCollectionViewCell.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/11.
//

import UIKit
import SnapKit

final class MetricCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MetricCollectionViewCell"
    
    struct ViewModel {
        let name: String
        let value: String
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        contentView.addSubviews(nameLabel, valueLabel)
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
        }
        valueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(nameLabel.snp.trailing).offset(5)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name + " : "
        valueLabel.text = viewModel.value
    }
}
