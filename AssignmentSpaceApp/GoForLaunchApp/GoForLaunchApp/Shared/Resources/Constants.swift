//
//  Constants.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 7.10.2025.
//

import UIKit

enum AppColors {
    static let accent: UIColor = UIColor(hex: "D15B0D")
    static let background: UIColor = UIColor(hex: "101318")
    static let cardBackground: UIColor = UIColor(hex: "1D2028")
}

enum AppStrings {
    static let welcomeText: String = "Welcome to GoForLaunch"
    static let defaultErrorMessage = "An unknown error occurred."

    static let onboardUpcomingTitle = "Upcoming Launches"
    static let onboardPastTitle = "Past Missions"
    static let onboardFavoritesTitle = "Your Favorite Launches"
    static let onboardSpacecraftTitle = "Discover Spacecraft"

    static let onboardUpcomingSubtitle = "Track all upcoming rocket missions live."
    static let onboardPastSubtitle = "Explore historic launches in detail."
    static let onboardFavoritesSubtitle = "Add your favorite missions for quick access."
    static let onboardSpacecraftSubtitle = "From rockets to capsules, explore space technology up close."
    
    static let onboardUpcomingImagePath = "RocketLaunchFirst"
    static let onboardPastImagePath = "RocketLaunchSecond"
    static let onboardFavoritesImagePath = "RocketLaunchThird"
    static let onboardSpacecraftImagePath = "RocketLaunchFourth"
}

enum ViewMetrics {
    static let viewElementSpacing: CGFloat = 16
    static let viewElementInsideSpacing: CGFloat = 16
    
    static let radius: CGFloat = 16
    
    static let topConstraint: CGFloat = 16
    static let leadingConstraint: CGFloat = 16
    static let trailingConstraint: CGFloat = -16
    static let bottomConstraint: CGFloat = -16
}

enum UserDefaultsKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
}
