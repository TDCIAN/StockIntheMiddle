//
//  SettingsViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/16.
//

import UIKit
import SafariServices

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SystemSettingsOption)
}

struct SystemSettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
}

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let isHidden: Bool
    let handler: (() -> Void)
}

final class SettingsViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(
            SettingTableViewCell.self,
            forCellReuseIdentifier: SettingTableViewCell.identifier
        )
        tableView.register(
            SwitchTableViewCell.self,
            forCellReuseIdentifier: SwitchTableViewCell.identifier
        )
        return tableView
    }()

    private var appVersion: String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else { return "1.0.0" }
        let versionBuild: String = version
        return versionBuild
    }

    var models: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTitleView()
        setTableView()
        configure()
    }

    private func setUpTitleView() {
        navigationItem.titleView = configNavTitleView(title: "SETTINGS")
    }

    private func setTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }

    private func configure() {
        models.append(Section(title: "System Settings", options: [
            .switchCell(model: SystemSettingsOption(
                title: "Dark Mode",
                icon: UIImage(systemName: "sun.max"),
                iconBackgroundColor: .systemBlue
            ))
        ]))

        models.append(Section(title: "App Info", options: [
            .staticCell(model: SettingsOption(
                title: "App Version \(self.appVersion)",
                icon: UIImage(systemName: "info.circle"),
                iconBackgroundColor: .systemBlue, isHidden: true) {

            }),
            .staticCell(model: SettingsOption(title: "Opensource License", icon: UIImage(systemName: "book"), iconBackgroundColor: .systemBlue, isHidden: false) {
                self.showOpensourceView()
            }),
            .staticCell(model: SettingsOption(title: "Privacy Policy", icon: UIImage(systemName: "person.fill.checkmark"), iconBackgroundColor: .systemBlue, isHidden: false) {
                self.tapPrivacyPolicyButton()
            })
        ]))

        models.append(Section(title: "Contact", options: [
            .staticCell(model: SettingsOption(
                title: "tdcian71@gmail.com",
                icon: UIImage(systemName: "mail"),
                iconBackgroundColor: .systemBlue,
                isHidden: true) {

            })
        ]))
    }

    private func showOpensourceView() {
        let openSourceVC = OpenSourceViewController()
        self.present(openSourceVC, animated: true, completion: nil)
    }

    private func tapPrivacyPolicyButton() {
        guard let privacyURL = URL(string: "https://github.com/TDCIAN/StockInTheMiddlePrivacyPolicy/blob/main/PrivacyPolicy.md") else { return }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safari = SFSafariViewController(url: privacyURL, configuration: config)
        safari.preferredBarTintColor = UIColor.white
        safari.preferredControlTintColor = UIColor.systemBlue

        present(safari, animated: true, completion: nil)
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
            return
        }
    }
}
