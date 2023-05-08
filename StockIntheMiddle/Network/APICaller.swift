//
//  APICaller.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

enum APIError: Error {
    case invalidURL
    case badStatus
    case decodingError
    case networkError
}

final class APICaller {
    
    static let shared = APICaller()
    
    private enum Endpoint: String {
        case search = "search"
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    private struct Constants {
        static var apiKey: String {
            return Bundle.main.object(forInfoDictionaryKey: "NEWS_KEY") as? String ?? "NO_KEY"
        }
        static let baseURL = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseURL + endpoint.rawValue

        var queryItems = [URLQueryItem]()

        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }

        queryItems.append(.init(name: "token", value: Constants.apiKey))

        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")

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
                    completion(.failure(APIError.decodingError))
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
    
    private func requestSingle<T: Codable>(url: URL?, expecting: T.Type) -> Single<T> {
        guard let url = url else {
            return Single.error(APIError.invalidURL)
        }

        let request = URLRequest(url: url)
        
        return RxAlamofire.requestData(request)
            .map { response, jsonData in
                if !(200..<300 ~= response.statusCode) {
                    throw APIError.badStatus
                }
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
                    return decodedData
                } catch {
                    throw APIError.decodingError
                }
            }
            .asSingle()
    }
    
    // MARK: Watchlist
    public func searchStock(query: String) -> Single<SearchResponse> {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return Single.error(APIError.invalidURL)
        }
        return requestSingle(
            url: url(for: .search, queryParams: ["q": safeQuery]),
            expecting: SearchResponse.self
        )
    }

    public func marketData(for symbol: String, numberOfDays: TimeInterval = 7) -> Single<MarketDataResponse> {
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
        return requestSingle(url: url, expecting: MarketDataResponse.self)
    }

    public func financialMetrics(for symbol: String) -> Single<FinancialMetricsResponse> {
        let url = url(
            for: .financials,
            queryParams: ["symbol": symbol, "metric": "all"]
        )
        return requestSingle(url: url, expecting: FinancialMetricsResponse.self)
    }

    // MARK: News
    func fetchNews(query: String) -> Single<[NewsStory]> {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return Single.error(APIError.invalidURL)
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
            return Single.error(APIError.networkError)
        }
        
        return requestSingle(url: url, expecting: [NewsStory].self)
    }
}
