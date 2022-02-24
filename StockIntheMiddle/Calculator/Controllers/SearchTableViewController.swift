//
//  SearchTableViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/24.
//

import UIKit
import Combine
import MBProgressHUD

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

    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: CalcSearchResults?
    @Published private var mode: Mode = .onboarding
    @Published private var searchQuery = String()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupTableView()
        observeForm()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
    }
    
    private func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
    }
    
    private func observeForm() {
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                guard !searchQuery.isEmpty else { return }
                showLoadingAnimation()
                self.apiService.fetchSymbolsPublisher(keywords: searchQuery).sink {
                    (completion) in
                    hideLoadingAnimation()
                    switch completion {
                    case .failure(let error):
                        print("performSearch - error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                } receiveValue: { (searchResults) in
                    print("performSearch - searchResults: \(searchResults)")
                    self.searchResults = searchResults
                    self.tableView.reloadData()
                    self.tableView.isScrollEnabled = true
                }.store(in: &self.subscribers)
            }.store(in: &subscribers)
        
        $mode.sink { mode in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
            case .search:
                self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
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
        apiService.fetchTimeSeriesMonthlyAdjustedPublisher(keywords: symbol).sink { [weak self] (completionResult) in
            self?.hideLoadingAnimation()
            switch completionResult {
            case .failure(let error):
                print("handleSelection - error: \(error.localizedDescription)")
            case .finished:
                break
            }
        } receiveValue: { [weak self] (timeSeriesMonthlyAdjusted) in
            self?.hideLoadingAnimation()
            print("handleSelection - success: \(timeSeriesMonthlyAdjusted.getMonthInfos())")
            let asset = Asset(searchResult: searchResult, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
            self?.performSegue(withIdentifier: "showCalculator", sender: asset)
            self?.searchController.searchBar.text = nil
        }.store(in: &subscribers)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalculator",
           let destination = segue.destination as? CalculatorTableViewController,
           let asset = sender as? Asset {
            destination.asset = asset
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
    
}
