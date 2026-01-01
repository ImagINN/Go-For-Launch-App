//
//  OnboardingViewController.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 8.10.2025.
//

import UIKit
import SwiftUI
import OnboardingKit

@available(iOS 17.0, *)
final class OnboardingViewController: UIViewController {
    
    private var hosting: UIHostingController<OnboardView>?
    private let viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel = OnboardingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Configuration
extension OnboardingViewController {
    private func configure() {
        let root = OnboardView(
            items: viewModel.items,
            titleText: viewModel.titleText,
            accent: Color(viewModel.accent),
            backgroundColor: Color(viewModel.background),
            onPrimaryAction: { [weak self] in
                self?.viewModel.primaryButtonTapped()
            }
        )
        
        let hc = UIHostingController(rootView: root)
        self.hosting = hc
        
        addChild(hc)
        view.addSubview(hc.view)
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hc.didMove(toParent: self)
    }
}

// MARK: - OnboardingViewModelDelegate
@available(iOS 17.0, *)

enum AppRouter {
    @MainActor
    static func setRoot(_ vc: UIViewController, animated: Bool = true) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        if animated {
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: { window.rootViewController = vc })
        } else {
            window.rootViewController = vc
        }
        window.makeKeyAndVisible()
    }
}

// MARK: - OnboardingViewModelDelegate
@available(iOS 17.0, *)
extension OnboardingViewController: OnboardingViewModelDelegate {
    func onboardingDidFinish() {
        finishOnboarding()
    }

    @MainActor
    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenOnboarding)
        AppRouter.setRoot(RootTabBarController())
    }
}

