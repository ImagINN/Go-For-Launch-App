//
//  UIImageView+Placeholder.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 12.10.2025.
//

import UIKit

extension UIImageView {
    func setPlaceholder(
        systemName: String = "photo",
        tint: UIColor = .lightGray,
        mode: UIView.ContentMode = .scaleAspectFit
    ) {
        image = UIImage(systemName: systemName)
        tintColor = tint
        contentMode = mode
    }
}
