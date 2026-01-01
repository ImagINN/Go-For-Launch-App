//
//  UIColor+Hex.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 8.10.2025.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var value: UInt64 = 0
        var colorHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if colorHex.hasPrefix("#") { colorHex.removeFirst() }
        
        Scanner(string: colorHex).scanHexInt64(&value)
        
        let red = CGFloat((value >> 16) & 0xFF) / 255
        let green = CGFloat((value >> 8) & 0xFF) / 255
        let blue = CGFloat(value & 0xFF) / 255
        
        self.init(
            red: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
    }
}
