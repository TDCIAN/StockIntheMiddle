//
//  NewsStoryTableViewCell.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/08.
//

import UIKit
import SDWebImage

final class NewsStoryTableViewCell: UITableViewCell {

    static let identifier = "NewsStoryTableViewCell"

    static let preferredHeight: CGFloat = 150

    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageURL: URL?

        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageURL = URL(string: model.image)
        }
    }

    private let sourceLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private let headlineLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
       let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()

    private let storyImageView: UIImageView = {
      let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)

        [storyImageView, sourceLabel, headlineLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }

        storyImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
            $0.width.height.equalTo(120)
        }

        sourceLabel.snp.makeConstraints {
            $0.top.equalTo(storyImageView.snp.top)
            $0.leading.equalToSuperview().inset(15)
        }

        headlineLabel.snp.makeConstraints {
            $0.top.equalTo(sourceLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(15)
            $0.height.lessThanOrEqualTo(75)
            $0.trailing.lessThanOrEqualTo(storyImageView.snp.leading).offset(-10)
        }

        dateLabel.snp.makeConstraints {
            $0.bottom.equalTo(storyImageView.snp.bottom)
            $0.leading.equalToSuperview().inset(15)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }

    public func configure(with viewModel: ViewModel) {
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        storyImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
    }
}
