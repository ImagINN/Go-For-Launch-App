//
//  LaunchListViewController.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 8.10.2025.
//

import UIKit

final class LaunchListViewController: UIViewController {
    
    private let filterViewModel = FilterViewModel()
    private var launchListViewModel: LaunchListViewModelProtocol = LaunchListViewModel(repository: LaunchRepository())
    
    private let containerStack = UIStackView()
    private let filterView = FilterView()
    private let tableView = UITableView()
    private var items: [Launch] = []
    
    private let pagingIndicator = UIActivityIndicatorView(style: .medium)
    private let footerHeight: CGFloat = 56
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration()
        launchListViewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationAppearance()
    }
    
}

extension LaunchListViewController: ViewBuilderProtocol {
    func configuration() {
        bindings()
        buildHierarchy()
        setupStyles()
        setupConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    func bindings() {
        filterView.onFilterChanged = { [weak self] newStatus in
            self?.filterViewModel.setSelected(newStatus)
        }
        
        filterView.onSearchChanged = { [weak self] text in
            self?.filterViewModel.setSearchText(text)
        }

        filterView.onTapFilter = { [weak self] in
            self?.filterViewModel.tapFilter()
        }
        
        filterViewModel.onStatusChanged = { [weak self] status in
            self?.filterView.render(status: status)
            self?.launchListViewModel.apply(status: status)
        }
        
        filterViewModel.onSearchChanged = { [weak self] query in
            self?.launchListViewModel.search(query: query)
        }
        
        launchListViewModel.onLoading = { [weak self] isLoading in
            guard let self else { return }
            isLoading ? self.showLoadingView() : self.hideLoadingView()
            self.updateEmptyState(isLoading: isLoading)
        }
        
        launchListViewModel.onPaging = { [weak self] isPagging in
            self?.tableView.setLoadingFooter(isPagging)
        }
        
        launchListViewModel.onError = { [weak self] message in
            guard let self else { return }
            self.showError(title: "Error", message: message)
            self.items = []
            self.tableView.reloadData()
            self.updateEmptyState(isLoading: false, error: message)
        }
        
        launchListViewModel.onNavigateDetail = { [weak self] id in
            guard let self else { return }
            let vc = LaunchDetailViewController(id: id)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        launchListViewModel.onItemsChanged = { [weak self] list in
            guard let self else { return }
            self.items = list
            self.tableView.reloadData()
            self.updateEmptyState(isLoading: false)
        }
    }
    
    private func updateEmptyState(isLoading: Bool, error: String? = nil) {
        if isLoading {
            tableView.backgroundView = nil
            return
        }
        if let error {
            tableView.backgroundView = EmptyStateView(
                title: "Something went wrong",
                message: error,
                image: UIImage(systemName: "exclamationmark.triangle"),
                actionTitle: "Try again later.",
                onTap: { [weak self] in self?.launchListViewModel.load() }
            )
            return
        }
        tableView.backgroundView = items.isEmpty
            ? EmptyStateView(
                title: "No launch yet",
                message: "When new launches are added, you can see them here.",
                image: UIImage(named: "GreyRocket"),
                actionTitle: "Refresh",
                onTap: { [weak self] in self?.launchListViewModel.load() }
            )
            : nil
    }
    
    func buildHierarchy() {
        [filterView, tableView].forEach(containerStack.addArrangedSubview(_:))
        view.addSubview(containerStack)
    }
    
    func setupStyles() {
        view.backgroundColor = AppColors.background
        
        containerStack.axis = .vertical
        containerStack.spacing = ViewMetrics.viewElementSpacing
        
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 220
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(LaunchListCell.self, forCellReuseIdentifier: LaunchListCell.reuseId)
    }
    
    func setupConstraints() {
        [
            containerStack,
            filterView,
            tableView
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ViewMetrics.topConstraint),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewMetrics.leadingConstraint),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ViewMetrics.trailingConstraint),
            containerStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ViewMetrics.bottomConstraint)
        ])
    }
}

extension LaunchListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let launch = items[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: LaunchListCell.reuseId, for: indexPath) as! LaunchListCell
        cell.configure(with: launch)
        (launchListViewModel as? LaunchListViewModel)?.loadNextPageIfNeeded(indexPath.row)
        return cell
    }
    
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        (launchListViewModel as LaunchListViewModelProtocol).didSelectItem(at: indexPath.row)
    }
}

private extension LaunchListViewController {
    func setupNavigationAppearance() {
        NavigationStyler.apply(style: .largeTitle, for: self, title: "Launches")
    }
}
