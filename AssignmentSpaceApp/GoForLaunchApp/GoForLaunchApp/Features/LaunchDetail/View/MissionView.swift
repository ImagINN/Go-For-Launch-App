//
//  MissionView.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import UIKit
import GoForLaunchAPI

final class MissionView: UIView {
    
    private let containerStack = UIStackView()
    private let titleLabel = UILabel()
    private let cardView = UIView()
    private let contentStack = UIStackView()
    
    private let nameLabel = UILabel()
    private let typeNameLabel = UILabel()
    private let orbitNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

extension MissionView: ViewBuilderProtocol {
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func buildHierarchy() {
        addSubview(containerStack)
        
        [titleLabel, cardView].forEach(containerStack.addArrangedSubview(_:))
        
        cardView.addSubview(contentStack)
        
        [
            nameLabel,
            typeNameLabel,
            orbitNameLabel,
            descriptionLabel
        ].forEach(contentStack.addArrangedSubview(_:))
    }
    
    func setupStyles() {
        backgroundColor = .clear
        
        containerStack.axis = .vertical
        containerStack.spacing = ViewMetrics.viewElementSpacing
        
        titleLabel.text = "Mission"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .white
        
        cardView.backgroundColor = AppColors.cardBackground
        cardView.layer.cornerRadius = ViewMetrics.radius
        
        contentStack.axis = .vertical
        contentStack.spacing = ViewMetrics.viewElementInsideSpacing / 2
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 0
    }
    
    func setupConstraints() {
        [containerStack, contentStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewMetrics.leadingConstraint),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: ViewMetrics.trailingConstraint),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ViewMetrics.bottomConstraint),
            
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: ViewMetrics.topConstraint),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: ViewMetrics.leadingConstraint),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: ViewMetrics.trailingConstraint),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: ViewMetrics.bottomConstraint),
        ])
    }

}

// MARK: Bindings
extension MissionView {
    @MainActor
    func configure(with detail: LaunchDetail) {
        let name  = detail.missionName ?? "—"
        let type  = detail.missionType ?? "—"
        let orbit = detail.orbitName ?? "—"
        let desc  = (detail.missionDescription?.isEmpty == false) ? detail.missionDescription! : "—"
        
        nameLabel.setStyledText(title: "Name", value: name)
        typeNameLabel.setStyledText(title: "Type", value: type)
        orbitNameLabel.setStyledText(title: "Orbit", value: orbit)
        descriptionLabel.text = desc
    }
    
    func prepareForReuse() {
        nameLabel.attributedText = nil
        typeNameLabel.attributedText = nil
        orbitNameLabel.attributedText = nil
        descriptionLabel.text = nil
    }
}
