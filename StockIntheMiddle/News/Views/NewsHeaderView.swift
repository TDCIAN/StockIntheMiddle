//
//  NewsHeaderView.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/08.
//

import UIKit
import SnapKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

final class NewsHeaderView: UITableViewHeaderFooterView {

    static let identifier = "NewsHeaderView"

    static let preferredHeight: CGFloat = 70

    weak var delegate: NewsHeaderViewDelegate?

    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }

    private let label: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()

    let button: UIButton = {
       let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()

    // MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(label, button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        button.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(45)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    @objc private func didTapButton() {
        delegate?.newsHeaderViewDidTapAddButton(self)
    }

    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
}
