//
//  StockDetailsViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import UIKit
import SafariServices

final class StockDetailsViewController: UIViewController {

    // MARK: - Properties
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]

    private let tableView: UITableView = {
       let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return table
    }()

    private var stories: [NewsStory] = []

    private var metrics: Metrics?

    // MARK: - Init
    init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        setUpCloseButton()
        setUpTable()
        fetchFinancialData()
        fetchNews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    // MARK: - Private
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }

    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }

    private func setUpTable() {
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100)
        )
    }

    private func fetchFinancialData() {
        let group = DispatchGroup()
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print("StockDetailVC - fetchFinancialData - error: \(error)")
                }
            }
        }

        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print("StockDetailVC - fetchFinancialData - error: \(error)")
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }

    private func fetchNews() {
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("StockDetailVC - fetchNews - error: \(error.localizedDescription)")
            }
        }
    }

    private func renderChart() {
        let headerView = StockDetailHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: (view.width * 0.7) + 100
            )
        )

        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics = self.metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52L High", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.TenDayAverageTradingVolume)"))
        }

        let change = candleStickData.getPercentage()
        headerView.configure(
            chartViewModel: .init(
                data: candleStickData.reversed().map { $0.close },
                showLegend: true,
                showAxis: true,
                fillColor: change < 0 ? .systemRed : .systemGreen
            ),
            metricViewModels: viewModels
        )
        tableView.tableHeaderView = headerView
    }

}

// MARK: - TableView
extension StockDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        header.delegate = self
        header.configure(
            with: .init(
                title: symbol.uppercased(),
                shouldShowAddButton: !PersistenceManager.shared.watchlistContains(symbol: symbol)
            )
        )
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        HapticsManager.shared.vibrateForSelection()
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

// MARK: - NewsHeaderViewDelegate
extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {

        HapticsManager.shared.vibrate(for: .success)

        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchList(
            symbol: symbol,
            companyName: companyName
        )

        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We've added \(companyName) to your watchlist.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
