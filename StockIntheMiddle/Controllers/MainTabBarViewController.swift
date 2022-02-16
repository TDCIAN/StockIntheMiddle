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
        
        let watchListVC = WatchListViewController()
        let newsVC = NewsViewController(type: .topStories)
        let settingsVC = SettingsViewController()
        
        watchListVC.title = "Stocks"
        watchListVC.tabBarItem.image = UIImage(systemName: "chart.bar.xaxis")
        
        newsVC.title = "News"
        newsVC.tabBarItem.image = UIImage(systemName: "newspaper.fill")
        
        settingsVC.title = "Settings"
        settingsVC.tabBarItem.image = UIImage(systemName: "gearshape.fill")

        let watchNav = UINavigationController(rootViewController: watchListVC)
        let newsNav = UINavigationController(rootViewController: newsVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)

        setViewControllers([watchNav, newsNav, settingsNav], animated: true)
    }
}
