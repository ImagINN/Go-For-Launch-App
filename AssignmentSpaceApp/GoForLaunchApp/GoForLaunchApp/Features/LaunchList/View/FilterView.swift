//
//  FilterView.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 8.10.2025.
//

import UIKit

enum LaunchStatusFilter: CaseIterable {
    case upcoming, previous, all
}

final class FilterView: UIView {
    
    private let containerView = UIView()
    private let contentStack = UIStackView()
    
    private let topRowStack = UIStackView()
    private let searchBar = UISearchBar(frame: .zero)
    private let filterButton = UIButton(type: .system)

    private let statusSegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Upcoming", "Previous", "All"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    var onTapFilter: (() -> Void)?
    var onFilterChanged: ((LaunchStatusFilter) -> Void)?
    var onSearchChanged: ((String) -> Void)?
    
    private var selected: LaunchStatusFilter = .upcoming {
        didSet { updateSelectionUI() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

extension FilterView: ViewBuilderProtocol {
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func buildHierarchy() {
        [filterButton, searchBar].forEach(topRowStack.addArrangedSubview(_:))
        [topRowStack, statusSegment].forEach(contentStack.addArrangedSubview(_:))
        
        containerView.addSubview(contentStack)
        addSubview(containerView)
    }
    
    func setupStyles() {
        backgroundColor = .clear
        
        contentStack.axis = .vertical
        contentStack.spacing = ViewMetrics.viewElementSpacing
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        
        topRowStack.axis = .horizontal
        topRowStack.alignment = .fill
        topRowStack.distribution = .fill
        
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.backgroundColor = AppColors.cardBackground
            textField.layer.cornerRadius = ViewMetrics.radius
            textField.attributedPlaceholder = NSAttributedString(
                string: "Search",
                attributes: [.foregroundColor: UIColor.lightGray]
            )
            textField.returnKeyType = .done
            textField.delegate = self
        }
        searchBar.searchTextField.leftView?.tintColor = .lightGray
        
        let icon = UIImage(systemName: "line.3.horizontal.decrease.circle")
        filterButton.setImage(icon, for: .normal)
        filterButton.tintColor = .white
        filterButton.backgroundColor = AppColors.cardBackground
        filterButton.layer.cornerRadius = ViewMetrics.radius
        filterButton.addTarget(self, action: #selector(didTapFilter), for: .touchUpInside)
        
        statusSegment.selectedSegmentTintColor = AppColors.accent
        statusSegment.backgroundColor = AppColors.cardBackground
        statusSegment.setTitleTextAttributes([
            .foregroundColor: UIColor.white
        ], for: .normal)
        statusSegment.setTitleTextAttributes([
            .foregroundColor: UIColor.black
        ], for: .selected)
        statusSegment.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)

        updateSelectionUI()
    }
        
    func setupConstraints() {
        [
            containerView,
            contentStack,
            searchBar,
            filterButton,
            statusSegment
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            filterButton.widthAnchor.constraint(equalToConstant: 44),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}

// MARK: - Bindings
extension FilterView {
    
    func render(status: LaunchStatusFilter) {
        selected = status
    }

    func render(search: String) {
        searchBar.text = search
    }
    
    @objc private func didTapFilter() { onTapFilter?() }

    @objc private func didChangeSegment(_ sender: UISegmentedControl) {
        let new: LaunchStatusFilter = (
            sender.selectedSegmentIndex == 1
        ) ? .previous : (
            sender.selectedSegmentIndex == 2
        ) ? .all : .upcoming
        
        selected = new
        onFilterChanged?(new)
    }
    
    private func apply(_ status: LaunchStatusFilter) { selected = status }
    
    func updateSelectionUI() {
        switch selected {
        case .upcoming: statusSegment.selectedSegmentIndex = 0
        case .previous: statusSegment.selectedSegmentIndex = 1
        case .all: statusSegment.selectedSegmentIndex = 2
        }
    }
}

// MARK: - UITextFieldDelegate
extension FilterView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FilterView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        onSearchChanged?(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onSearchChanged?(searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
}
