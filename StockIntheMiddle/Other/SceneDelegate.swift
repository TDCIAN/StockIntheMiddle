//
//  SceneDelegate.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/05.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    /// Our main app window
    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let vc = MainTabBarViewController()
        let navVC = UINavigationController(rootViewController: vc)
//        window.backgroundColor = .systemBackground
        window.rootViewController = navVC
        window.makeKeyAndVisible()
        
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if UserDefaults.standard.bool(forKey: Constants.IS_DARK_MODE) {
            window?.overrideUserInterfaceStyle = .dark
        } else {
            window?.overrideUserInterfaceStyle = .light
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

