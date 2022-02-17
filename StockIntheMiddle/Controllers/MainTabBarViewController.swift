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
        let newsVC = NewsViewController(type: .topStories)
        let settingsVC = SettingsViewController()
        
        watchListVC.title = "Stocks"
        watchListVC.tabBarItem.image = UIImage(systemName: "chart.bar.xaxis")
        watchListVC.navigationItem.largeTitleDisplayMode = .always
        
        newsVC.title = "News"
        newsVC.tabBarItem.image = UIImage(systemName: "newspaper.fill")
        newsVC.navigationItem.largeTitleDisplayMode = .always
        
        settingsVC.title = "Settings"
        settingsVC.tabBarItem.image = UIImage(systemName: "gearshape.fill")
        settingsVC.navigationItem.largeTitleDisplayMode = .always

        let watchNav = UINavigationController(rootViewController: watchListVC)
        let newsNav = UINavigationController(rootViewController: newsVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)

        setViewControllers([watchNav, newsNav, settingsNav], animated: true)
    }
}
