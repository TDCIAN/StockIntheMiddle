//
//  NewsViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import UIKit
import SafariServices
import SnapKit
import RxSwift
import RxCocoa

/// Controller to show news
final class NewsViewController: UIViewController, UIAnimatable {
    let disposeBag = DisposeBag()
    
    /// Type of news
    enum `Type` {
        case topStories
        case company(symbol: String)
        
        /// Title for given type
        var title: String {
            switch self {
            case .topStories:
                return "Market News"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: - Properties
    private var searchTimer: Timer?
    
    private let searchButtonTapped = PublishRelay<Void>()
    private var queryString: String = ""
//    private var queryString = Observable<String>.of("")
    
    /// Collection of models
    private var stories: [NewsStory] = []
    
    var newsData = PublishSubject<[NewsStory]>()
    
    /// Instance of a type
    private let type: Type
    
    /// Primary news view
    let newsTableView: UITableView = {
       let table = UITableView()
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        table.rowHeight = NewsStoryTableViewCell.preferredHeight
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        return table
    }()
    
    let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()
    
    // MARK: - Init
    
    /// Create VC with type
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTitleView()
        setNavigationItems()
        setTableView()
        bind()
//        fetchNews(with: "")
    }
    
    private func setUpTitleView() {
        let titleView = UIView()
        let label = UILabel()
        label.text = "News"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        titleView.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
        }
        navigationItem.titleView = titleView
    }
    
    private func setNavigationItems() {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Search news with keyword"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
    }
    
    private func setTableView() {
//        newsTableView.dataSource = self
//        newsTableView.delegate = self
        view.addSubview(newsTableView)
        newsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        view.addSubview(noResultsLabel)
        noResultsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
        }
    }
    
    private func bind() {
//        APICaller.shared.fetchAllNews()
//            .asObservable()
//            .compactMap { data -> [NewsStory] in
//                guard case .success(let value) = data else {
//                    return []
//                }
//                return value
//            }
//            .bind(to: self.cellData)
//            .disposed(by: disposeBag)
//
//        self.cellData
//            .asDriver(onErrorJustReturn: [])
//            .drive(newsTableView.rx.items) { tableView, row, data in
//                let index = IndexPath(row: row, section: 0)
//                let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: index) as! NewsStoryTableViewCell
//                let viewModel = NewsStoryTableViewCell.ViewModel(model: data)
//                cell.configure(with: viewModel)
//                return cell
//            }
//            .disposed(by: disposeBag)
        
        APICaller.shared.fetchAllNews()
            .asObservable()
            .compactMap { data -> [NewsStory] in
                guard case .success(let value) = data else {
                    return []
                }
                return value
            }
            .asDriver(onErrorJustReturn: [])
            .drive(newsTableView.rx.items(cellIdentifier: NewsStoryTableViewCell.identifier, cellType: NewsStoryTableViewCell.self)) { row, data, cell in
                let viewModel = NewsStoryTableViewCell.ViewModel(model: data)
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(
            newsTableView.rx.modelSelected(NewsStory.self),
            newsTableView.rx.itemSelected
        )
        .bind { [weak self] news, indexPath in
            HapticsManager.shared.vibrateForSelection()
            self?.newsTableView.deselectRow(at: indexPath, animated: true)
            guard let url = URL(string: news.url) else {
                self?.presentFailedToOpenAlert()
                return
            }
            self?.open(url: url)
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private
    
    /// Fetch news models
    private func fetchNews(with query: String) {
        self.showLoadingAnimation()
        if query.isEmpty {
            APICaller.shared.news(for: type) { [weak self] result in
                self?.hideLoadingAnimation()
                switch result {
                case .success(let stories):
                    DispatchQueue.main.async {
                        self?.stories = stories
                        self?.newsTableView.isHidden = stories.isEmpty
                        self?.noResultsLabel.isHidden  = !stories.isEmpty
                        self?.newsTableView.reloadData()
                    }
                case .failure(let error):
                    print("NewsVC - fetchNews - error: \(error)")
                }
            }
        } else {
            APICaller.shared.news(for: .company(symbol: query)) { [weak self] result in
                self?.hideLoadingAnimation()
                switch result {
                case .success(let stories):
                    DispatchQueue.main.async {
                        self?.stories = stories
                        self?.newsTableView.isHidden = stories.isEmpty
                        self?.noResultsLabel.isHidden  = !stories.isEmpty
                        self?.newsTableView.reloadData()
                    }
                case .failure(let error):
                    print("NewsVC - fetchNews - error: \(error)")
                }
            }
        }
    }
    
    /// Open a story
    /// - Parameter url: URL to open
    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    /// Present an alert to show an error occurred when opening story
    private func presentFailedToOpenAlert() {
        HapticsManager.shared.vibrate(for: .error)
        let alert = UIAlertController(title: "Unable to Open", message: "We were unable to open the article.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}


extension NewsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.queryString = ""
        fetchNews(with: self.queryString)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.queryString = searchText
        if !self.queryString.isEmpty {
            searchTimer?.invalidate()
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                self.fetchNews(with: self.queryString)
            })
        }
    }
    
}

// MARK: - UITableViewDelegate
//extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return stories.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
//            fatalError()
//        }
//        cell.configure(with: .init(model: stories[indexPath.row]))
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return NewsStoryTableViewCell.preferredHeight
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { return nil }
//        header.configure(with: NewsHeaderView.ViewModel(
//            title: self.type.title,
//            shouldShowAddButton: false
//        ))
//        return header
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return NewsHeaderView.preferredHeight
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        HapticsManager.shared.vibrateForSelection()
//
//        // open news story
//        let story = stories[indexPath.row]
//        guard let url = URL(string: story.url) else {
//            presentFailedToOpenAlert()
//            return
//        }
//        open(url: url)
//    }
//

//}
