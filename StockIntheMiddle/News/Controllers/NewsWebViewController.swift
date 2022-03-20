//
//  NewsWebViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/03/20.
//

import UIKit
import WebKit
import SnapKit

final class NewsWebViewController: UIViewController {
    
    let url: URL
    let webView = WKWebView()

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupWebView()
    }
    
    private func setupWebView() {
        view = webView
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
}
