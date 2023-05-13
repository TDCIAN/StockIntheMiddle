//
//  SearchTableViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/24.
//

import UIKit
import MBProgressHUD
import SnapKit
import RxSwift
import RxCocoa

class SearchTableViewController: UITableViewController, UIAnimatable {

    private enum Mode {
        case onboarding
        case search
    }

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()

    private var searchResults: CalcSearchResults?

    private let disposeBag = DisposeBag()
    private let mode = BehaviorRelay<Mode>(value: .onboarding)
    private let searchQuery = PublishRelay<String>()

    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitleView()
        setupNavigationBar()
        setupTableView()
        observeForm()
    }

    private func setUpTitleView() {
        navigationItem.titleView = configNavTitleView(title: "CALCULATOR")
    }

    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }

    private func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.addSubview(noResultsLabel)
        noResultsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
        }
    }

    private func observeForm() {
        searchQuery
            .debounce(RxTimeInterval.milliseconds(750), scheduler: MainScheduler.instance)
            .bind { [unowned self] searchQuery in
                if searchQuery.isEmpty {
                    self.searchResults = nil
                    self.tableView.reloadData()
                    self.tableView.isScrollEnabled = false
                } else {
                    self.showLoadingAnimation()
                    APICaller.shared.fetchStockSymbols(keywords: searchQuery)
                        .subscribe { calcSearchResults in
                            self.hideLoadingAnimation()
                            self.searchResults = calcSearchResults
                            if let items = self.searchResults?.items {
                                if items.isEmpty {
                                    self.tableView.reloadData()
                                    self.tableView.isScrollEnabled = false
                                    self.noResultsLabel.isHidden = false
                                } else {
                                    self.noResultsLabel.isHidden = true
                                    self.tableView.reloadData()
                                    self.tableView.isScrollEnabled = true
                                }
                            }
                        }.disposed(by: disposeBag)
                }
            }.disposed(by: disposeBag)
        
        
        mode.bind { mode in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
            case .search:
                self.tableView.backgroundView = nil
            }
        }.disposed(by: disposeBag)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchTableViewCell.preferredHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.row]
            cell.configure(with: searchResult)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.item]
            let symbol = searchResult.symbol
            handleSelection(for: symbol, searchResult: searchResult)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func handleSelection(for symbol: String, searchResult: CalcSearchResult) {
        showLoadingAnimation()
        APICaller.shared.fetchTimeSeriesMonthlyAdjusted(keywords: symbol)
            .subscribe { [weak self] timeSeriesMonthlyAdjusted in
                self?.hideLoadingAnimation()
                let asset = Asset(searchResult: searchResult, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
                let calculatorVc = CalculatorTableViewController()
                calculatorVc.asset = asset
                self?.navigationController?.pushViewController(calculatorVc, animated: true)
                self?.searchController.searchBar.text = nil
            }.disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalculator",
           let destination = segue.destination as? CalculatorTableViewController,
           let asset = sender as? Asset {
            destination.asset = asset
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text else { return }
        if searchQuery.isEmpty {
            self.searchQuery.accept("")
            mode.accept(.onboarding)
            noResultsLabel.isHidden = true
        } else {
            self.searchQuery.accept(searchQuery)
            mode.accept(.search)
        }
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        mode.accept(.search)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchQuery.accept("")
        mode.accept(.onboarding)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery.accept(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchQuery.accept("")
        mode.accept(.onboarding)
    }
}
