//
//  MainTabBarViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/16.
//

import UIKit

enum TabBarItem: CaseIterable {
    case watchlist
    case calculator
    case news
    case settings
    
    var title: String {
        switch self {
        case .watchlist:
            return "Watchlist"
        case .calculator:
            return "Calculator"
        case .news:
            return "News"
        case .settings:
            return "Settings"
        }
    }
    
    var icon: (default: UIImage?, selected: UIImage?) {
        switch self {
        case .watchlist:
            return (UIImage(systemName: "chart.line.uptrend.xyaxis"), UIImage(systemName: "chart.line.uptrend.xyaxis"))
        case .calculator:
            return (UIImage(systemName: "chart.bar.fill"), UIImage(systemName: "chart.bar.fill"))
        case .news:
            return (UIImage(systemName: "newspaper.fill"), UIImage(systemName: "newspaper.fill"))
        case .settings:
            return (UIImage(systemName: "gearshape.fill"), UIImage(systemName: "gearshape.fill"))
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .watchlist:
            return WatchListViewController()
        case .calculator:
            return SearchTableViewController()
        case .news:
            return NewsViewController(type: .topStories)
        case .settings:
            return SettingsViewController()
        }
    }
}

class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tabBarViewControllers: [UIViewController] = TabBarItem.allCases.map { tabCase in
            let viewController = tabCase.viewController
            viewController.tabBarItem = UITabBarItem(
                title: tabCase.title,
                image: tabCase.icon.default,
                selectedImage: tabCase.icon.selected
            )
            return UINavigationController(rootViewController: viewController)
        }
        
        self.viewControllers = tabBarViewControllers

//        let watchListVC = WatchListViewController()
//        let calculatorVC = SearchTableViewController()
//        let newsVC = NewsViewController(type: .topStories)
//        let settingsVC = SettingsViewController()
//
//        watchListVC.title = "Watchlist"
//        watchListVC.tabBarItem.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
//
//        calculatorVC.title = "Calculator"
//        calculatorVC.tabBarItem.image = UIImage(systemName: "chart.bar.fill")
//
//        newsVC.title = "News"
//        newsVC.tabBarItem.image = UIImage(systemName: "newspaper.fill")
//
//        settingsVC.title = "Settings"
//        settingsVC.tabBarItem.image = UIImage(systemName: "gearshape.fill")
//
//        let watchNav = UINavigationController(rootViewController: watchListVC)
//        let calcNav = UINavigationController(rootViewController: calculatorVC)
//        let newsNav = UINavigationController(rootViewController: newsVC)
//        let settingsNav = UINavigationController(rootViewController: settingsVC)
//
//        setViewControllers([watchNav, calcNav, newsNav, settingsNav], animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
