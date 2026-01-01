//
//  ProgramView.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import UIKit
import GoForLaunchAPI

final class ProgramView: UIView {
    
    private let containerStack = UIStackView()
    private let titleLabel = UILabel()
    private let cardView = UIView()
    private let contentStack = UIStackView()
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private var currentImageLoadTask: Task<Void, Never>?
    private var imageLoader: ImageLoaderProtocol = ImageLoaderService()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { currentImageLoadTask?.cancel() }
}

extension ProgramView: ViewBuilderProtocol {
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func buildHierarchy() {
        addSubview(containerStack)
        
        [titleLabel, cardView].forEach(containerStack.addArrangedSubview(_:))
        
        [imageView, contentStack].forEach(cardView.addSubview(_:))
        
        [nameLabel, descriptionLabel].forEach(contentStack.addArrangedSubview(_:))
    }
    
    func setupStyles() {
        backgroundColor = .clear
        
        containerStack.axis = .vertical
        containerStack.spacing = ViewMetrics.viewElementSpacing
        
        titleLabel.text = "Program"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .white
        
        cardView.backgroundColor = AppColors.cardBackground
        cardView.layer.cornerRadius = ViewMetrics.radius
        cardView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentStack.axis = .vertical
        contentStack.spacing = ViewMetrics.viewElementInsideSpacing / 2
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 0
    }
    
    func setupConstraints() {
        [containerStack, contentStack, imageView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewMetrics.leadingConstraint),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: ViewMetrics.trailingConstraint),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ViewMetrics.bottomConstraint),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 9.0/16.0),

            contentStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ViewMetrics.topConstraint),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: ViewMetrics.leadingConstraint),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: ViewMetrics.trailingConstraint),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: ViewMetrics.bottomConstraint),
        ])
    }
}

// MARK: Bindings
extension ProgramView {
    @MainActor
    func configure(with detail: LaunchDetail, imageLoader: ImageLoaderProtocol = ImageLoaderService()) {
        self.imageLoader = imageLoader
        
        guard let program = detail.programs.first,
              (program.name?.isEmpty == false || program.description?.isEmpty == false || program.imageURL?.isEmpty == false) else {
            isHidden = true
            return
        }
        isHidden = false
        
        nameLabel.setStyledText(title: "Name", value: program.name ?? "—")
        descriptionLabel.text = (program.description?.isEmpty == false) ? program.description : "—"
        
        currentImageLoadTask?.cancel()
        imageView.image = nil
        if let urlStr = program.imageURL, let url = URL(string: urlStr) {
            currentImageLoadTask = Task { [weak self] in
                guard let self else { return }
                do {
                    let img = try await imageLoader.loadImage(from: url)
                    if !Task.isCancelled {
                        await MainActor.run { self.imageView.image = img }
                    }
                } catch {
                    if !Task.isCancelled {
                        await MainActor.run { self.imageView.setPlaceholder() }
                    }
                }
            }
        } else {
            imageView.setPlaceholder()
        }
    }
    
    func prepareForReuse() {
        currentImageLoadTask?.cancel()
        imageView.image = nil
        nameLabel.attributedText = nil
        descriptionLabel.text = nil
        isHidden = false
    }
}
