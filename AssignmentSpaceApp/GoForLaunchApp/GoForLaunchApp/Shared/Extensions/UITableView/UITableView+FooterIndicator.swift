//
//  UITableView+FooterIndicator
//  GoForLaunchApp
//
//  Created by Gokhan on 12.10.2025.
//

import UIKit

private var footerKey: UInt8 = 0
private var spinnerKey: UInt8 = 0

extension UITableView {

    func setLoadingFooter(_ isLoading: Bool, height: CGFloat = 56) {

        let footer: LoadingFooterView = {
            if let f = objc_getAssociatedObject(self, &footerKey) as? LoadingFooterView { return f }
            
            let f = LoadingFooterView(frame: .zero)
            objc_setAssociatedObject(self, &footerKey, f, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return f
        }()

        if isLoading {
            if footer.frame.height != height {
                footer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
            }
            tableFooterView = footer
            footer.indicator.startAnimating()

            var inset = contentInset
            inset.bottom = height
            contentInset = inset
        } else {
            footer.indicator.stopAnimating()
            footer.frame.size.height = 0
            tableFooterView = footer
            
            var inset = contentInset
            inset.bottom = 0
            contentInset = inset
        }

        layoutIfNeeded()
    }
}

final class LoadingFooterView: UIView {
    let indicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
