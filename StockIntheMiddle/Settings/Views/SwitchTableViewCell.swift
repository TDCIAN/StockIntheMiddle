//
//  SwitchTableViewCell.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/20.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    static let identifier = "SwitchTableViewCell"

    private let iconContainer: UIView = {
       let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let label: UILabel = {
       let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let settingSwitch: UISwitch = {
       let mySwitch = UISwitch()
        mySwitch.onTintColor = .systemBlue
        mySwitch.addTarget(self, action: #selector(handleSwitch(sender:)), for: .touchUpInside)
        return mySwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [iconContainer, label, settingSwitch].forEach {
            contentView.addSubview($0)
        }
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)

        let imageSize: CGFloat = size/1.5
        iconImageView.frame = CGRect(
            x: (size - imageSize) / 2,
            y: (size - imageSize) / 2,
            width: imageSize,
            height: imageSize)

        settingSwitch.sizeToFit()
        settingSwitch.frame = CGRect(
            x: contentView.frame.size.width - settingSwitch.frame.size.width - 20,
            y: (contentView.frame.size.height - settingSwitch.frame.size.height) / 2,
            width: settingSwitch.frame.size.width,
            height: settingSwitch.frame.size.height
        )

        label.frame = CGRect(
            x: 25 + iconContainer.frame.size.width,
            y: 0,
            width: contentView.frame.size.width - 15 - iconContainer.frame.size.width - 10,
            height: contentView.frame.size.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
        settingSwitch.isOn = ConfigManager.shared.isDarkMode
    }

    public func configure(with model: SystemSettingsOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
        settingSwitch.isOn = ConfigManager.shared.isDarkMode
    }

    @objc func handleSwitch(sender: UISwitch) {
        if sender.isOn {
            contentView.window?.overrideUserInterfaceStyle = .dark
            ConfigManager.shared.isDarkMode = true
        } else {
            contentView.window?.overrideUserInterfaceStyle = .light
            ConfigManager.shared.isDarkMode = false
        }
    }
}
