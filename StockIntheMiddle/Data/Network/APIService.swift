//
//  APIService.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/24.
//

import Foundation

//struct APIService {
//
//    enum APIServiceError: Error {
//        case encoding
//        case badRequest
//    }
//
////    static var newsKey: String {
////        return Bundle.main.object(forInfoDictionaryKey: "NEWS_KEY") as? String ?? "NO_KEY"
////    }
//
//    static var key: String {
//        let keys: [String] = ["PX40A1II4YND2OGE", "5GIMV9VKZDVHLJTQ", "9ENLS3NPR86NE79F"]
//        return keys.randomElement() ?? "PX40A1II4YND2OGE"
////        return Bundle.main.object(forInfoDictionaryKey: "CALC_KEY") as? String ?? "NO_KEY"
//    }
//
//    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<CalcSearchResults, Error> {
//
//        let result = parseQuery(text: keywords)
//        var symbol = ""
//        switch result {
//        case .success(let query):
//            symbol = query
//        case .failure(let error):
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//
//        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(symbol)&apikey=\(APIService.key)"
//
//        let urlResult = parseURL(urlString: urlString)
//
//        switch urlResult {
//        case .success(let url):
//            return URLSession.shared.dataTaskPublisher(for: url)
//                .map({ $0.data })
//                .decode(type: CalcSearchResults.self, decoder: JSONDecoder())
//                .receive(on: RunLoop.main)
//                .eraseToAnyPublisher()
//        case .failure(let error):
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//    }
//
//    func fetchTimeSeriesMonthlyAdjustedPublisher(keywords: String) -> AnyPublisher<TimeSeriesMonthlyAdjusted, Error> {
//
//        let result = parseQuery(text: keywords)
//        var symbol = ""
//        switch result {
//        case .success(let query):
//            symbol = query
//        case .failure(let error):
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//
//        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(symbol)&apikey=\(APIService.key)"
//
//        let urlResult = parseURL(urlString: urlString)
//
//        switch urlResult {
//        case .success(let url):
//            return URLSession.shared.dataTaskPublisher(for: url)
//                .map({ $0.data })
//                .decode(type: TimeSeriesMonthlyAdjusted.self, decoder: JSONDecoder())
//                .receive(on: RunLoop.main)
//                .eraseToAnyPublisher()
//        case .failure(let error):
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//    }
//
//    private func parseQuery(text: String) -> Result<String, Error> {
//        if let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
//            return .success(query)
//        } else {
//            return .failure(APIServiceError.encoding)
//        }
//
//    }
//
//    private func parseURL(urlString: String) -> Result<URL, Error> {
//        if let url = URL(string: urlString) {
//            return .success(url)
//        } else {
//            return .failure(APIServiceError.badRequest)
//        }
//    }
//}
