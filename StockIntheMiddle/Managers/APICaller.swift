//
//  APICaller.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import Foundation
import RxSwift

final class APICaller {

    static let shared = APICaller()

    private struct Constants {
        static let apiKey = "c805soiad3i8n3bhbcmg"
        static let sandbaxApiKey = "sandbox_c805soiad3i8n3bhbcn0"
        static let baseURL = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }

    private init() {}

    // MARK: - Public
    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(
            url: url(for: .search, queryParams: ["q": safeQuery]),
            expecting: SearchResponse.self,
            completion: completion
        )
    }

    public func news(for type: NewsViewController.`Type`, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        switch type {
        case .topStories:
            request(
                url: url(for: .topStories, queryParams: ["category": "general"]),
                expecting: [NewsStory].self,
                completion: completion
            )
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            request(
                url: url(
                    for: .companyNews,
                    queryParams: [
                        "symbol": symbol,
                        "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                        "to": DateFormatter.newsDateFormatter.string(from: today)
                    ]
                ),
                expecting: [NewsStory].self,
                completion: completion
            )
        }
    }

    func fetchNews(query: String) -> Single<Result<[NewsStory], Error>> {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return .just(.failure(APIError.invalidURL))
        }
        var endPoint: Endpoint = .topStories
        var queryParams: [String: String] = [:]
        if safeQuery.isEmpty {
            endPoint = .topStories
            queryParams = [
                "category": "general"
            ]
        } else {
            endPoint = .companyNews
            let today = Date()
            let oneWeekBack = today.addingTimeInterval(-(Constants.day * 7))
            queryParams = [
                "symbol": safeQuery,
                "from": DateFormatter.newsDateFormatter.string(from: oneWeekBack),
                "to": DateFormatter.newsDateFormatter.string(from: today)
            ]
        }
        guard let url = url(
            for: endPoint,
            queryParams: queryParams
        ) else {
            return .just(.failure(APIError.networkError))
        }
        print("APICaller - fetchNews \n (1) safeQuery: \(safeQuery) \n (2) endPoint: \(endPoint), \n (3) queryParams: \(queryParams), \n (4) url: \(url)")
        let request = URLRequest(url: url)
        return URLSession.shared.rx.data(request: request)
            .map { data in
                do {
                    let newsData = try JSONDecoder().decode([NewsStory].self, from: data)
                    return .success(newsData)
                } catch {
                    return .failure(APIError.noDataReturned)
                }
            }
            .catch { _ in
                .just(.failure(APIError.networkError))
            }
            .asSingle()
    }

    public func marketData(for symbol: String, numberOfDays: TimeInterval = 7, completion: @escaping (Result<MarketDataResponse, Error>) -> Void) {
        let today = Date().addingTimeInterval(-(Constants.day))
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        let url = url(
            for: .marketData,
               queryParams: [
                    "symbol": symbol,
                    "resolution": "1",
                    "from": "\(Int(prior.timeIntervalSince1970))",
                    "to": "\(Int(today.timeIntervalSince1970))"
               ]
        )
        request(url: url, expecting: MarketDataResponse.self, completion: completion)
    }

    public func financialMetrics(for symbol: String, completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void) {
        let url = url(
            for: .financials,
               queryParams: ["symbol": symbol, "metric": "all"]
        )
        request(
            url: url,
            expecting: FinancialMetricsResponse.self,
            completion: completion
        )
    }

    // MARK: - Private
    private enum Endpoint: String {
        case search = "search"
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }

    private enum APIError: Error {
        case invalidURL
        case noDataReturned
        case networkError
    }

    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseURL + endpoint.rawValue

        var queryItems = [URLQueryItem]()

        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }

        queryItems.append(.init(name: "token", value: Constants.apiKey))

        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        print("APICaller - url: \(urlString)")
        return URL(string: urlString)
    }

    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            // Invalid url
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
