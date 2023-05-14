//
//  NewsViewModel.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2023/05/14.
//

import Foundation

protocol NewsViewModelAction {
    func searchNews(query: String)
}

protocol NewsViewModelType: AnyObject, NewsViewModelAction {
    var delegate:
}
