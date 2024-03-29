//
//  WatchListTableViewCell.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/09.
//

import UIKit

protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

final class WatchListTableViewCell: UITableViewCell {

    static let identifier = "WatchListTableViewCell"

    weak var delegate: WatchListTableViewCellDelegate?

    static let preferredHeight: CGFloat = 75

    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String // formatted
        let changeColor: UIColor // red or green
        let changePercentage: String // formatted
        let chartViewModel: StockChartView.ViewModel
    }

    private let symbolLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    private let nameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let priceLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .right
        return label
    }()

    private let changeLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private let miniChartView: StockChartView = {
       let chart = StockChartView()
        chart.isUserInteractionEnabled = false
        chart.clipsToBounds = true
        chart.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return chart
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(
            symbolLabel,
            nameLabel,
            miniChartView,
            priceLabel,
            changeLabel
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        symbolLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview().offset(-12.5)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview().offset(12.5)
            $0.width.lessThanOrEqualTo(contentView.width * 0.4)
        }

        priceLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview().offset(-12.5)
            $0.width.lessThanOrEqualTo(contentView.width * 0.2)
        }

        changeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview().offset(12.5)
            $0.width.lessThanOrEqualTo(contentView.width * 0.2)
        }

        miniChartView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.30)
            $0.height.equalTo(contentView.height - 15)
            $0.trailing.equalToSuperview().inset(90)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }

    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        priceLabel.textColor = viewModel.changeColor
        changeLabel.text = viewModel.changePercentage
        changeLabel.textColor = viewModel.changeColor
        // Configure chart
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}
