//
//  ViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/05.
//

import UIKit
import AppTrackingTransparency
import FloatingPanel
import SnapKit
import MBProgressHUD
import RxSwift
import RxCocoa

final class WatchListViewController: UIViewController, UIAnimatable {
    
    private let disposeBag = DisposeBag()

    private var searchTimer: Timer?

    private var panel: FloatingPanelController?

    private var watchlistMap: [String: [CandleStick]] = [:]

    private var viewModels: [WatchListTableViewCell.ViewModel] = []

    private lazy var watchListTableView: UITableView = {
       let table = UITableView()
        table.register(
            WatchListTableViewCell.self,
            forCellReuseIdentifier: WatchListTableViewCell.identifier
        )
        return table
    }()

    private var observer: NSObjectProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        requestTrackingAuth()
        setUpTitleView()
        setUpSearchController()
        setUpTableView()
        setUpFloatingPanel()
        setUpObserver()
        fetchWatchlistData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        watchListTableView.frame = view.bounds
    }

    // MARK: - Private
    private func requestTrackingAuth() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("requestTrackingAuth - authorized")
                case .denied:
                    print("requestTrackingAuth - denied")
                case .notDetermined:
                    print("requestTrackingAuth - notDetermined")
                case .restricted:
                    print("requestTrackingAuth - restricted")
                @unknown default:
                    print("requestTrackingAuth - default")
                }
            }
        }
    }
    
    private func setUpTitleView() {
        navigationItem.titleView = configNavTitleView(title: "WATCHLIST")
    }

    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.placeholder = "Search stocks and add to watchlist"
        navigationItem.searchController = searchVC
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setUpTableView() {
        view.addSubview(watchListTableView)
        watchListTableView.delegate = self
        watchListTableView.dataSource = self
        watchListTableView.isHidden = true
    }
    
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchlistData()
        }
    }

    private func fetchWatchlistData() {
        showLoadingAnimation()
        let symbols = PersistenceManager.shared.watchlist

        createPlaceholderViewModels()

        let group = DispatchGroup()

        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            APICaller.shared.marketData(for: symbol)
                .subscribe(on: MainScheduler.instance)
                .subscribe { [weak self] data in
                    defer {
                        group.leave()
                    }
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                } onFailure: { error in
                    print(#fileID, #function, #line, "- marketData error: \(error)")
                }.disposed(by: disposeBag)
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.watchListTableView.reloadData()
            self?.watchListTableView.isHidden = false
            self?.hideLoadingAnimation()
        }
    }

    private func createPlaceholderViewModels() {
        let symbols = PersistenceManager.shared.watchlist
        symbols.forEach { item in
            viewModels.append(
                .init(
                    symbol: item,
                    companyName: UserDefaults.standard.string(forKey: item) ?? "Company",
                    price: "0.00",
                    changeColor: UIColor.systemGreen,
                    changePercentage: "0.00",
                    chartViewModel:
                            .init(
                                data: [],
                                showLegend: false,
                                showAxis: false,
                                fillColor: .clear
                            )
                )
            )
        }
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
        watchListTableView.reloadData()
    }

    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = candleSticks.getPercentage()
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: String.percentage(from: changePercentage),
                    chartViewModel:
                            .init(
                                data: candleSticks.reversed().map { $0.close },
                                showLegend: false,
                                showAxis: false,
                                fillColor: changePercentage < 0 ? .systemRed : .systemGreen
                            )
                )
            )
        }
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
    }

    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return String.formatted(number: closingPrice)
    }
    
}

// MARK: - UISearchResultsUpdating

extension WatchListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                  return
              }

        searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APICaller.shared.searchStock(query: query)
                .subscribe(on: MainScheduler.instance)
                .subscribe { response in
                    var result: [SearchResult] = []
                    response.result.forEach { searchResult in
                        if !searchResult.displaySymbol.contains(".") {
                            result.append(searchResult)
                        }
                    }
                    resultsVC.update(with: result)
                } onFailure: { error in
                    resultsVC.update(with: [])
                    print("WatchListVC - updateSearchResults - error: \(error)")
                }.disposed(by: self.disposeBag)
        })
    }
}

// MARK: - SearchResultsViewControllerDelegate
extension WatchListViewController: SearchResultsViewControllerDelegate {

    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()

        HapticsManager.shared.vibrateForSelection()

        let vc = StockDetailsViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description
        )
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

// MARK: - FloatingPanelController
extension WatchListViewController: FloatingPanelControllerDelegate {
    class CustomFloatingPanelLayout: FloatingPanelLayout {
        let position: FloatingPanelPosition = .bottom
        let initialState: FloatingPanelState = .tip
        let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
    
    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.layout = CustomFloatingPanelLayout()
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.newsTableView)
        panel.delegate = self
        
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -8)
        shadow.radius = 8
        appearance.shadows = [shadow]
        appearance.cornerRadius = 16
        panel.surfaceView.grabberHandle.isHidden = false
        panel.surfaceView.appearance = appearance
    }
}

// MARK: - TableView
extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WatchListTableViewCell.identifier,
            for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()

            PersistenceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)

            viewModels.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .automatic)

            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        HapticsManager.shared.vibrateForSelection()

        let viewModel = viewModels[indexPath.row]
        let vc = StockDetailsViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchlistMap[viewModel.symbol] ?? []
        )
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

// MARK: - WatchListTableViewCellDelegate
extension WatchListViewController: WatchListTableViewCellDelegate {

    func didUpdateMaxWidth() {
        watchListTableView.reloadData()
    }
}
