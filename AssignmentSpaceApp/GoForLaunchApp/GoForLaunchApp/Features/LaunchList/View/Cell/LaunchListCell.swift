//
//  LaunchListCell.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 10.10.2025.
//

import UIKit
import GoForLaunchAPI

final class LaunchListCell: UITableViewCell {
    static let reuseId = "LaunchListCell"
    
    private let containerView = UIView()
    private let contentStack = UIStackView()
    private let topRowStack = UIStackView()
    private let statusStack = UIStackView()
    
    private let thumbnailImage = UIImageView()
    private let headerStack = UIStackView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let statusNameLabel = UILabel()
    private let statusDescriptionLabel = UILabel()
    
    private let imageLoader: ImageLoaderProtocol = ImageLoaderService()
    private var currentImageLoadTask: Task<Void, Never>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configuration()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configuration()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentImageLoadTask?.cancel()
        thumbnailImage.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        statusNameLabel.text = nil
        statusDescriptionLabel.text = nil
    }

}

extension LaunchListCell: ViewBuilderProtocol {
    func configuration() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        buildHierarchy()
        setupStyles()
        setupConstraints()
        selectionStyle = .none
    }
    
    func buildHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(contentStack)
        
        [topRowStack, statusStack].forEach(contentStack.addArrangedSubview(_:))
        
        [thumbnailImage, headerStack].forEach(topRowStack.addArrangedSubview(_:))
        [titleLabel, dateLabel].forEach(headerStack.addArrangedSubview(_:))
        
        [statusNameLabel, statusDescriptionLabel].forEach(statusStack.addArrangedSubview(_:))
    }
    
    func setupStyles() {
        containerView.backgroundColor = AppColors.cardBackground
        containerView.layer.cornerRadius = ViewMetrics.radius
        
        contentStack.axis = .vertical
        contentStack.spacing = ViewMetrics.viewElementSpacing
        
        topRowStack.axis = .horizontal
        topRowStack.spacing = ViewMetrics.viewElementInsideSpacing
        
        statusStack.axis = .vertical
        statusStack.spacing = ViewMetrics.viewElementInsideSpacing
        
        headerStack.axis = .vertical
        headerStack.spacing = ViewMetrics.viewElementInsideSpacing
        
        thumbnailImage.contentMode = .scaleAspectFit
        thumbnailImage.clipsToBounds = true
        thumbnailImage.layer.cornerRadius = ViewMetrics.radius / 2
        thumbnailImage.setContentHuggingPriority(.required, for: .horizontal)
        thumbnailImage.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.lineBreakMode = .byTruncatingTail
        
        dateLabel.textColor = .white.withAlphaComponent(0.8)
        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        statusNameLabel.textColor = .lightGray
        statusNameLabel.font = .systemFont(ofSize: 14, weight: .regular)
        
        statusDescriptionLabel.textColor = .lightGray
        statusDescriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        
        titleLabel.numberOfLines = 2
        dateLabel.numberOfLines = 1
        statusNameLabel.numberOfLines = 1
        statusDescriptionLabel.numberOfLines = 0

        [titleLabel, dateLabel, statusNameLabel, statusDescriptionLabel].forEach {
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
    }
    
    func setupConstraints() {
        [containerView, contentStack, thumbnailImage].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: ViewMetrics.bottomConstraint),

            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ViewMetrics.topConstraint),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ViewMetrics.leadingConstraint),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: ViewMetrics.trailingConstraint),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: ViewMetrics.bottomConstraint),

            thumbnailImage.widthAnchor.constraint(equalToConstant: 64),
            thumbnailImage.heightAnchor.constraint(equalToConstant: 64),
        ])
    }
}

extension LaunchListCell {
    func configure(with launch: Launch) {
        titleLabel.text = launch.name
        dateLabel.text = launch.dateUTC.map { DateFormatter.defaultDateFormat.string(from: $0) } ?? "Tarih Bilinmiyor"
        
        let statusName = launch.statusName ?? "Unknown"
        statusNameLabel.text = "Status: \(statusName)"
        statusDescriptionLabel.text = launch.statusDescription?.isEmpty == false ? launch.statusDescription : "—"
        
        if let urlStr = launch.thumbnailURL, let url = URL(string: urlStr) {
            currentImageLoadTask = Task {
                do {
                    let image = try await imageLoader.loadImage(from: url)
                    if !Task.isCancelled {
                        await MainActor.run {
                            self.thumbnailImage.image = image
                        }
                    }
                } catch {
                    if !Task.isCancelled {
                        await MainActor.run {
                            thumbnailImage.setPlaceholder()
                        }
                    }
                }
            }
        } else {
            thumbnailImage.setPlaceholder()
        }
    }
}
