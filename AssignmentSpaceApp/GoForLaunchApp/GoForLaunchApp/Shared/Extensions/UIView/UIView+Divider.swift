//
//  UIView+Divider.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import UIKit

extension UIView {

    static func divider(color: UIColor = .separator, height: CGFloat = 1.0) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        return view
    }
}
