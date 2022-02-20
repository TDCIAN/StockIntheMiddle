//
//  SettingsViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/16.
//

import UIKit

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
}

struct SettingsSwitchOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    var isOn: Bool
}

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

final class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        return table
    }()
    
    var models: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTitleView()
        setTableView()
        configure()
    }
    
    private func setUpTitleView() {
        let titleView = UIView()
        let label = UILabel()
        label.text = "Settings"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        titleView.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
        }
        navigationItem.titleView = titleView
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    private func configure() {
        models.append(Section(title: "System Settings", options: [
            .switchCell(model: SettingsSwitchOption(
                title: "Dark Mode",
                icon: UIImage(systemName: "sun.max"),
                iconBackgroundColor: .systemGray4,
                isOn: ConfigManager.getInstance.isDarkMode
            ))
        ]))
        
        models.append(Section(title: "General", options: [
            .staticCell(model: SettingsOption(title: "Wifi", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemPink) {
                
            }),
            .staticCell(model: SettingsOption(title: "Bluetooth", icon: UIImage(systemName: "network"), iconBackgroundColor: .link) {
                
            }),
            .staticCell(model: SettingsOption(title: "Airplane Model", icon: UIImage(systemName: "airplane"), iconBackgroundColor: .systemGreen) {
                
            }),
            .staticCell(model: SettingsOption(title: "iCloud", icon: UIImage(systemName: "cloud"), iconBackgroundColor: .systemOrange) {
                
            })
        ]))
        
        models.append(Section(title: "Information", options: [
            .staticCell(model: SettingsOption(title: "Wifi", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemPink) {
                
            }),
            .staticCell(model: SettingsOption(title: "Bluetooth", icon: UIImage(systemName: "network"), iconBackgroundColor: .link) {
                
            }),
            .staticCell(model: SettingsOption(title: "Airplane Model", icon: UIImage(systemName: "airplane"), iconBackgroundColor: .systemGreen) {
                
            }),
            .staticCell(model: SettingsOption(title: "iCloud", icon: UIImage(systemName: "cloud"), iconBackgroundColor: .systemOrange) {
                
            })
        ]))
        
        models.append(Section(title: "Apps", options: [
            .staticCell(model: SettingsOption(title: "Wifi", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemPink) {
                
            }),
            .staticCell(model: SettingsOption(title: "Bluetooth", icon: UIImage(systemName: "network"), iconBackgroundColor: .link) {
                
            }),
            .staticCell(model: SettingsOption(title: "Airplane Model", icon: UIImage(systemName: "airplane"), iconBackgroundColor: .systemGreen) {
                
            }),
            .staticCell(model: SettingsOption(title: "iCloud", icon: UIImage(systemName: "cloud"), iconBackgroundColor: .systemOrange) {
                
            })
        ]))
    }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        switch model.self {
        case .staticCell(model: let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
            cell.configure(with: model)
            return cell
        case .switchCell(model: let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier, for: indexPath) as? SwitchTableViewCell else { return UITableViewCell() }
            cell.configure(with: model)
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(model: let model):
            model.handler()
        case .switchCell:
            print("스위치 셀 만짐")
        }
    }
}

