//
//  NavigationStyler.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import UIKit

enum NavStyle {
    case largeTitle
    case standard
}

enum NavigationStyler {
    static func apply(style: NavStyle, for vc: UIViewController, title: String) {
        vc.title = title

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        let nav = vc.navigationController?.navigationBar
        nav?.standardAppearance = appearance
        nav?.scrollEdgeAppearance = appearance
        nav?.compactAppearance = appearance
        nav?.tintColor = .white
        vc.navigationItem.backButtonDisplayMode = .minimal

        switch style {
        case .largeTitle:
            nav?.prefersLargeTitles = true
            vc.navigationItem.largeTitleDisplayMode = .always
        case .standard:
            nav?.prefersLargeTitles = false
            vc.navigationItem.largeTitleDisplayMode = .never
        }
    }
}
