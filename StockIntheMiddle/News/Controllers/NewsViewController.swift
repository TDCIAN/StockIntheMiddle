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

final class NewsViewController: UIViewController, UIAnimatable {
    let disposeBag = DisposeBag()

    enum NewsType {
        case topStories
        case company(symbol: String)

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
    private let searchButtonTapped = PublishRelay<Void>()
    var newsData = PublishSubject<[NewsStory]>()

    private let newsType: NewsType

    let newsTableView: UITableView = {
       let table = UITableView()
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        table.rowHeight = NewsStoryTableViewCell.preferredHeight
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
    init(type: NewsType) {
        self.newsType = type
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
        navigationItem.titleView = configNavTitleView(title: "NEWS")
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
            .observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
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
            .do(onNext: { [weak self] newsResult in
                self?.hideLoadingAnimation()
                self?.newsTableView.isHidden = newsResult.isEmpty
                self?.noResultsLabel.isHidden = !newsResult.isEmpty
            })
            .asDriver(onErrorJustReturn: [])
            .drive(newsTableView.rx.items(
                cellIdentifier: NewsStoryTableViewCell.identifier,
                cellType: NewsStoryTableViewCell.self)) { _, data, cell in
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
//            let newsWebViewController = NewsWebViewController(url: url)
//            self?.navigationController?.pushViewController(newsWebViewController, animated: true)
            self?.open(url: url)
        }
        .disposed(by: disposeBag)
    }

    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

    private func presentFailedToOpenAlert() {
        HapticsManager.shared.vibrate(for: .error)
        let alert = UIAlertController(title: "Unable to Open", message: "We were unable to open the article.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
