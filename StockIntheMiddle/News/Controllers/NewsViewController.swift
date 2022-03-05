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
        searchController.searchBar.placeholder = "Search news with ticker"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func setTableView() {
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
        self.navigationItem.searchController?.searchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.milliseconds(750), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                self?.showLoadingAnimation()
            })
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .flatMapLatest { query -> Single<Result<[NewsStory], Error>> in
                return APICaller.shared.fetchNews(query: query)
            }
            .observe(on: MainScheduler.instance)
            .compactMap { data -> [NewsStory] in
                var newsResult: [NewsStory] = []
                switch data {
                case .success(let value):
                    newsResult = value
                case .failure(let error):
                    print("NewsVC - fetchNews - error: \(error)")
                }
                return newsResult
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] newsResult in
                self?.hideLoadingAnimation()
                self?.newsTableView.isHidden = newsResult.isEmpty
                self?.noResultsLabel.isHidden = !newsResult.isEmpty
            })
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


//extension NewsViewController: UISearchBarDelegate {
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
////        tableView.reloadData()
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        self.queryString = ""
//        fetchNews(with: self.queryString)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        self.queryString = searchText
//        if !self.queryString.isEmpty {
//            searchTimer?.invalidate()
//            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
//                self.fetchNews(with: self.queryString)
//            })
//        }
//    }
//
//}
