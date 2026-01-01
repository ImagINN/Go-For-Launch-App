//
//  HeaderView.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 12.10.2025.
//

import UIKit
import GoForLaunchAPI

final class HeaderView: UIView {
    
    private let overlayLabelStack = UIStackView()
    private let headerImage = UIImageView()
    private let launchNameLabel = UILabel()
    private let launchStatusNameLabel = UILabel()
    private let launchStatusDescriptionLabel = UILabel()
    
    private var currentImageLoadTask: Task<Void, Never>?
    private var imageLoader: ImageLoaderProtocol = ImageLoaderService()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { currentImageLoadTask?.cancel() }
}

extension HeaderView: ViewBuilderProtocol {
    
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func buildHierarchy() {
        addSubview(headerImage)
        addSubview(overlayLabelStack)
        
        [launchNameLabel, launchStatusNameLabel, launchStatusDescriptionLabel]
            .forEach(overlayLabelStack.addArrangedSubview(_:))
    }
    
    func setupStyles() {
        backgroundColor = .clear

        overlayLabelStack.axis = .vertical
        overlayLabelStack.spacing = ViewMetrics.viewElementInsideSpacing / 2
        overlayLabelStack.isLayoutMarginsRelativeArrangement = true
        overlayLabelStack.layoutMargins = .init(
            top: 0,
            left: 16,
            bottom: 16,
            right: 16
        )
        
        headerImage.contentMode = .scaleAspectFill
        headerImage.clipsToBounds = true
        
        launchNameLabel.textColor = .white
        launchNameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        
        launchStatusDescriptionLabel.textColor = .lightGray
        launchStatusDescriptionLabel.font = .systemFont(ofSize: 14)
        launchStatusDescriptionLabel.numberOfLines = 3
        launchStatusDescriptionLabel.lineBreakMode = .byTruncatingTail

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        overlayLabelStack.layer.insertSublayer(gradient, at: 0)

        overlayLabelStack.layoutSubviewsHandler = { [weak overlayLabelStack] in
            overlayLabelStack?.layer.sublayers?.first?.frame = overlayLabelStack?.bounds ?? .zero
        }
    }
    
    func setupConstraints() {
        [overlayLabelStack, headerImage].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            headerImage.topAnchor.constraint(equalTo: topAnchor),
            headerImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerImage.bottomAnchor.constraint(equalTo: bottomAnchor),

            overlayLabelStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayLabelStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayLabelStack.bottomAnchor.constraint(equalTo: headerImage.bottomAnchor)
        ])
    }
}

// MARK: Bindings
extension HeaderView {
    @MainActor
    func configure(with detail: LaunchDetail, imageLoader: ImageLoaderProtocol = ImageLoaderService()) {
        self.imageLoader = imageLoader
        
        launchNameLabel.text = detail.name
        let status = detail.statusName ?? "Unknown"
        launchStatusNameLabel.setStyledText(title: "Status", value: status)
        launchStatusDescriptionLabel.text = detail.statusDescription?.isEmpty == false
            ? detail.statusDescription
            : "—"
        
        currentImageLoadTask?.cancel()
        headerImage.image = nil
        if let urlStr = detail.imageURL ?? detail.rocketImageURL,
           let url = URL(string: urlStr) {
            currentImageLoadTask = Task { [weak self] in
                guard let self else { return }
                do {
                    let img = try await imageLoader.loadImage(from: url)
                    if !Task.isCancelled {
                        await MainActor.run { self.headerImage.image = img }
                    }
                } catch {
                    if !Task.isCancelled {
                        await MainActor.run {
                            self.headerImage.setPlaceholder()
                        }
                    }
                }
            }
        } else {
            headerImage.setPlaceholder()
        }
    }
    
    func prepareForReuse() {
        currentImageLoadTask?.cancel()
        headerImage.image = nil
        launchNameLabel.text = nil
        launchStatusNameLabel.attributedText = nil
        launchStatusDescriptionLabel.text = nil
    }
}
