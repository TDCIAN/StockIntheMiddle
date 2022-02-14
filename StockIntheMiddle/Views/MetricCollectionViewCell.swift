//
//  MetricCollectionViewCell.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/11.
//

import UIKit

/// Metric table cell
final class MetricCollectionViewCell: UICollectionViewCell {
    
    /// Cell id
    static let identifier = "MetricCollectionViewCell"
    
    /// Metric table cell viewModel
    struct ViewModel {
        let name: String
        let value: String
    }
    
    private let nameLabel: UILabel = {
       let label = UILabel()
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
        contentView.addSubviews(nameLabel, valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        valueLabel.sizeToFit()
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 15, y: 0, width: nameLabel.width, height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 3, y: 0, width: valueLabel.width, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
    /// Configure view
    /// - Parameter viewModel: View ViewModel
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name + " : "
        valueLabel.text = viewModel.value
    }
}
