//
//  UIViewController+Showables.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 9.10.2025.
//

import UIKit

protocol LoadingShowable {
    func showLoadingView()
    func hideLoadingView()
}

protocol ErrorShowable {
    func showError(title: String, message: String)
}

extension UIViewController: LoadingShowable, ErrorShowable {
    
    private var _spinnerTag: Int { 999_777 }
    
    func showLoadingView() {
        if Thread.isMainThread {
            applyShow()
        } else {
            DispatchQueue.main.async { [weak self] in self?.applyShow() }
        }
    }
    
    func hideLoadingView() {
        if Thread.isMainThread {
            view.viewWithTag(_spinnerTag)?.removeFromSuperview()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.view.viewWithTag(self?._spinnerTag ?? -1)?.removeFromSuperview()
            }
        }
    }
    
    func showError(title: String, message: String) {
        let presentBlock = { [weak self] in
            guard let self else { return }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
        }
        if Thread.isMainThread { presentBlock() } else { DispatchQueue.main.async(execute: presentBlock) }
    }
    
    private func applyShow() {
        guard view.viewWithTag(_spinnerTag) == nil else { return }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.tag = _spinnerTag
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: visualEffectView.contentView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: visualEffectView.contentView.centerYAnchor)
        ])
        indicator.startAnimating()
        
        view.addSubview(visualEffectView)
    }
}
