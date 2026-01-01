//
//  RootTabBarController.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import UIKit

final class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        let launchesVC = LaunchListViewController()
        let launchesNav = UINavigationController(rootViewController: launchesVC)
        launchesNav.tabBarItem = UITabBarItem(
            title: "Launches",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let favVC = FavouriteLaunchViewController()
        let favNav = UINavigationController(rootViewController: favVC)
        favNav.tabBarItem = UITabBarItem(
            title: "Favourites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        viewControllers = [launchesNav, favNav]
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.cardBackground
        appearance.stackedLayoutAppearance.normal.iconColor = .lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        appearance.stackedLayoutAppearance.selected.iconColor = AppColors.accent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.isTranslucent = false
        view.backgroundColor = AppColors.background
    }
}
