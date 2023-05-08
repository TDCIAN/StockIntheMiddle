//
//  StockDetailsViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa
import SnapKit

final class StockDetailsViewController: UIViewController {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]

    private lazy var newsTableView: UITableView = {
       let tableView = UITableView()
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100)
        )
        return tableView
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
        setLayout()
        setUpCloseButton()
        bindFinancialData()
        bindNews()
    }
    
    private func setLayout() {
        view.addSubview(newsTableView)
        newsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

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

    private func bindFinancialData() {
        let group = DispatchGroup()
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketData(for: symbol)
                .subscribe(on: MainScheduler.instance)
                .subscribe { [weak self] data in
                    defer {
                        group.leave()
                    }
                    self?.candleStickData = data.candleSticks
                } onFailure: { error in
                    print(#fileID, #function, #line, "- bindFinancialData error: \(error)")
                }.disposed(by: disposeBag)
        }

        group.enter()
        APICaller.shared.financialMetrics(for: symbol)
            .subscribe(on: MainScheduler.instance)
            .subscribe { [weak self] response in
                defer {
                    group.leave()
                }
                let metrics = response.metric
                self?.metrics = metrics
            } onFailure: { error in
                print("StockDetailVC - fetchFinancialData - error: \(error)")
            }.disposed(by: disposeBag)
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }

    private func bindNews() {
        APICaller.shared.fetchNews(query: symbol)
            .observe(on: MainScheduler.instance)
            .compactMap({ news in
                return news
            })
            .subscribe(
                onSuccess: { [weak self] news in
                    self?.stories = news
                    self?.newsTableView.reloadData()
                }, onError: { error in
                    print(#fileID, #function, #line, "- bindNews error: \(error)")
                }
            ).disposed(by: disposeBag)
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
            viewModels.append(.init(name: "52W High", value: String(format: "%.2f", metrics.AnnualWeekHigh)))
            viewModels.append(.init(name: "52W Low", value: String(format: "%.2f", metrics.AnnualWeekLow)))
            viewModels.append(.init(name: "52W Return", value: String(format: "%.2f", metrics.AnnualWeekPriceReturnDaily)))
            viewModels.append(.init(name: "10D Volume", value: String(format: "%.2f", metrics.TenDayAverageTradingVolume)))
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
        newsTableView.tableHeaderView = headerView
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
