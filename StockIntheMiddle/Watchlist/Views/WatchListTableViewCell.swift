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

    static let preferredHeight: CGFloat = 60

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
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let nameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    private let priceLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    private let changeLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()

    private let miniChartView: StockChartView = {
       let chart = StockChartView()
        chart.isUserInteractionEnabled = false
        chart.clipsToBounds = true
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
            $0.top.equalToSuperview().inset(10)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(symbolLabel.snp.bottom)
            $0.width.lessThanOrEqualTo(contentView.width * 0.4)
        }

        priceLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(10)
        }

        changeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(priceLabel.snp.bottom)
        }

        miniChartView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.33)
            $0.height.equalTo(contentView.height - 12)
            $0.trailing.equalToSuperview().inset(80)
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
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        // Configure chart
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}
