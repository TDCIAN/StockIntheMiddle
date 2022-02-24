//
//  MainTabBarViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/16.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let watchListVC = WatchListViewController()
        let calculatorVC = SearchTableViewController()
        let newsVC = NewsViewController(type: .topStories)
        let settingsVC = SettingsViewController()
        
        watchListVC.title = "Watchlist"
        watchListVC.tabBarItem.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        
        calculatorVC.title = "Calculator"
        calculatorVC.tabBarItem.image = UIImage(systemName: "chart.bar.fill")
        
        newsVC.title = "News"
        newsVC.tabBarItem.image = UIImage(systemName: "newspaper.fill")
        
        settingsVC.title = "Settings"
        settingsVC.tabBarItem.image = UIImage(systemName: "gearshape.fill")

        let watchNav = UINavigationController(rootViewController: watchListVC)
        let calcNav = UINavigationController(rootViewController: calculatorVC)
        let newsNav = UINavigationController(rootViewController: newsVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)

        setViewControllers([watchNav, calcNav, newsNav, settingsNav], animated: true)
    }
}
