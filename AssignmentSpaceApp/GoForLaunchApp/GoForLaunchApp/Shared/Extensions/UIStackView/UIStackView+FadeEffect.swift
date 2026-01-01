//
//  UIStackView+FadeEffect.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 12.10.2025.
//

import UIKit

extension UIStackView {
    private struct Holder {
        static var handlerKey: UInt8 = 0
    }
    
    var layoutSubviewsHandler: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &Holder.handlerKey) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &Holder.handlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler?()
    }
}
