//
//  UITableView+EmptyState.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 12.10.2025.
//

import UIKit

struct EmptyState {
    var title: String
    var message: String
    var image: UIImage?
    var actionTitle: String?
    var onTap: (() -> Void)?
}

extension UITableView {
    func setEmptyStateView(state: EmptyState = .init(
        title: "No content to show",
        message: "Try again later",
        image: UIImage(systemName: "xmark.circle"),
        actionTitle: nil,
        onTap: nil)
    ) {
        backgroundView = EmptyStateView(state: state)
    }
}

final class EmptyStateView: UIView {
 
    private let stack = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    private var state: EmptyState {
        didSet { render() }
    }
    
    private var actionHandler: (() -> Void)?

    init(state: EmptyState) {
        self.state = state
        super.init(frame: .zero)
        configuration()
    }

    convenience init(
        title: String = "No content to show",
        message: String = "Try again later",
        image: UIImage? = UIImage(systemName: "xmark.circle"),
        actionTitle: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.init(state: .init(title: title, message: message, image: image, actionTitle: actionTitle, onTap: onTap))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(_ newState: EmptyState, animated: Bool = true) {
        if animated {
            UIView.transition(with: stack, duration: 0.25, options: .transitionCrossDissolve) {
                self.state = newState
            }
        } else {
            self.state = newState
        }
    }
}

extension EmptyStateView: ViewBuilderProtocol {
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
        render()
    }

    func buildHierarchy() {
        addSubview(stack)
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descLabel)
        stack.addArrangedSubview(actionButton)
    }

    func setupStyles() {
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.backgroundColor = .clear

        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .white
        
        descLabel.font = .preferredFont(forTextStyle: .body)
        descLabel.textColor = .lightGray
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = AppColors.accent
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        actionButton.configuration = config
        actionButton.addAction(
            UIAction { [weak self] _ in self?.actionHandler?() },
            for: .touchUpInside
        )
    }

    func setupConstraints() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
    }
}

private extension EmptyStateView {
    func render() {
        titleLabel.text = state.title
        descLabel.text = state.message
        imageView.image = state.image
        actionButton.setTitle(state.actionTitle, for: .normal)
        actionButton.isHidden = (state.actionTitle == nil)
        actionHandler = state.onTap
        imageView.isHidden = (state.image == nil)
    }
}
