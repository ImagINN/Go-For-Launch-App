//
//  SceneDelegate.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 7.10.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let winScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: winScene)
        window.backgroundColor = AppColors.background

        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenOnboarding) {
            window.rootViewController = RootTabBarController()
        } else {
            let onboardingNav = UINavigationController(rootViewController: OnboardingViewController())
            window.rootViewController = onboardingNav
        }

        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) { }
    
    func sceneDidEnterBackground(_ scene: UIScene) { (UIApplication.shared.delegate as? AppDelegate)?.saveContext() }
}
