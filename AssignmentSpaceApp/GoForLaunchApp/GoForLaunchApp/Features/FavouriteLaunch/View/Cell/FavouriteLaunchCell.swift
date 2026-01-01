//
//  FavouriteLaunchCell.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import UIKit
import GoForLaunchAPI

final class FavouriteLaunchCell: UITableViewCell {
    static let reuseID = "FavouriteLaunchCell"

    private let containerStack = UIStackView()
    private let cardView = UIView()
    private let contentStack = UIStackView()
    
    private let thumbnailImage = UIImageView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let dateLabel = UILabel()
    
    private var currentImageLoadTask: Task<Void, Never>?
    private var imageLoader: ImageLoaderProtocol = ImageLoaderService()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configuration()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { currentImageLoadTask?.cancel() }
}

extension FavouriteLaunchCell: ViewBuilderProtocol {
    
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func buildHierarchy() {
        contentView.addSubview(containerStack)
        
        containerStack.addArrangedSubview(cardView)
        
        [thumbnailImage, contentStack].forEach(cardView.addSubview(_:))
        [nameLabel, statusLabel ,dateLabel].forEach(contentStack.addArrangedSubview(_:))
    }
    
    func setupStyles() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        selectionStyle = .none
        
        containerStack.axis = .vertical
        containerStack.spacing = ViewMetrics.viewElementSpacing
        
        cardView.backgroundColor = AppColors.cardBackground
        cardView.layer.cornerRadius = ViewMetrics.radius
        cardView.clipsToBounds = true

        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.clipsToBounds = true
        
        contentStack.axis = .vertical
        contentStack.spacing = ViewMetrics.viewElementInsideSpacing / 2
    }
    
    func setupConstraints() {
        [containerStack, cardView, contentStack, thumbnailImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: ViewMetrics.bottomConstraint),

            cardView.topAnchor.constraint(equalTo: containerStack.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: containerStack.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: containerStack.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: containerStack.bottomAnchor),

            thumbnailImage.topAnchor.constraint(equalTo: cardView.topAnchor),
            thumbnailImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            thumbnailImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            thumbnailImage.heightAnchor.constraint(equalTo: thumbnailImage.widthAnchor, multiplier: 9.0/16.0),

            contentStack.topAnchor.constraint(equalTo: thumbnailImage.bottomAnchor, constant: ViewMetrics.topConstraint),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: ViewMetrics.leadingConstraint),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: ViewMetrics.trailingConstraint),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: ViewMetrics.bottomConstraint),
        ])
    }
}

extension FavouriteLaunchCell {
    func configure(with fav: FavouriteLaunch) {
        nameLabel.setStyledText(title: "Name", value: fav.name ?? "—")
        statusLabel.setStyledText(title: "Status", value: fav.statusName ?? "—")
        
        if let d = fav.dateUTC {
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yyyy HH:mm"
            dateLabel.setStyledText(title: "Date", value: df.string(from: d))
        } else {
            dateLabel.setStyledText(title: "Date", value: "—")
        }

        if let s = fav.thumbnailURL, let url = URL(string: s) {
            currentImageLoadTask?.cancel()
            currentImageLoadTask = Task { [weak self] in
                guard let self else { return }
                do {
                    let img = try await imageLoader.loadImage(from: url)
                    if !Task.isCancelled { await MainActor.run { self.thumbnailImage.image = img } }
                } catch {
                    if !Task.isCancelled { await MainActor.run { self.thumbnailImage.setPlaceholder() } }
                }
            }
        } else {
            thumbnailImage.setPlaceholder()
        }
    }
}
