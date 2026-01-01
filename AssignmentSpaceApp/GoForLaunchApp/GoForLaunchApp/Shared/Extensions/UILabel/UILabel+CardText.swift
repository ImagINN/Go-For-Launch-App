//
//  UILabel+CardText.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import UIKit

extension UILabel {
    func setStyledText(title: String, value: String) {
        
        let fullText = "\(title): \(value)"
        
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.white
            ]
        )
        
        attributed.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 14, weight: .semibold),
            range: (fullText as NSString).range(of: title)
        )
        
        self.attributedText = attributed
        self.numberOfLines = 0
    }
}
