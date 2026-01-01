//
//  OnboardingViewModel.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 8.10.2025.
//

import UIKit
import OnboardingKit

protocol OnboardingViewModelDelegate: AnyObject {
    func onboardingDidFinish()
}

@available(iOS 17.0, *)
final class OnboardingViewModel {
    
    weak var delegate: OnboardingViewModelDelegate?
    
    // MARK: Outputs
    let items: [OnboardItem]
    let titleText: String
    let accent: UIColor
    let background: UIColor
    
    init(
        items: [OnboardItem] = [
            .init(
                title: AppStrings.onboardUpcomingTitle,
                subTitle: AppStrings.onboardUpcomingSubtitle,
                image: .named(AppStrings.onboardUpcomingImagePath)
            ),
            .init(
                title: AppStrings.onboardPastTitle,
                subTitle: AppStrings.onboardPastSubtitle,
                image: .named(AppStrings.onboardPastImagePath)
            ),
            .init(
                title: AppStrings.onboardFavoritesTitle,
                subTitle: AppStrings.onboardFavoritesSubtitle,
                image: .named(AppStrings.onboardFavoritesImagePath)
            ),
            .init(
                title: AppStrings.onboardSpacecraftTitle,
                subTitle: AppStrings.onboardSpacecraftSubtitle,
                image: .named(AppStrings.onboardSpacecraftImagePath)
            )
        ],
        titleText: String = AppStrings.welcomeText,
        accent: UIColor = AppColors.accent,
        background: UIColor = AppColors.background
    ) {
        self.items = items
        self.titleText = titleText
        self.accent = accent
        self.background = background
    }
    
    // MARK: Inputs
    func primaryButtonTapped() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenOnboarding)
        delegate?.onboardingDidFinish()
    }
}
