//
//  FavouriteLaunchViewController.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import UIKit

final class FavouriteLaunchViewController: UIViewController {
    
    private var viewModel: FavouriteLaunchListViewModelProtocol = FavouriteLaunchListViewModel(
        repo: FavouritesRepository()
    )

    private let containerStack = UIStackView()
    private let tableView = UITableView()
    private var items: [FavouriteLaunch] = []

    private let searchBar = UISearchBar(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        bindViewModel()
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationAppearance()
        viewModel.load()
    }
}

extension FavouriteLaunchViewController: ViewBuilderProtocol {
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    private func bindViewModel() {
        viewModel.onItemsChanged = { [weak self] list in
            self?.items = list
            self?.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] error in
            self?.showError(title: "Error", message: error.localizedDescription)
        }
    }

    func buildHierarchy() {
        view.addSubview(containerStack)
        containerStack.addArrangedSubview(searchBar)
        containerStack.addArrangedSubview(tableView)
    }

    func setupStyles() {
        view.backgroundColor = AppColors.background

        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.translatesAutoresizingMaskIntoConstraints = false

        searchBar.searchBarStyle = .minimal
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
        searchBar.delegate = self

        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FavouriteLaunchCell.self,
                           forCellReuseIdentifier: FavouriteLaunchCell.reuseID)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewMetrics.leadingConstraint),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ViewMetrics.trailingConstraint),
            containerStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

private extension FavouriteLaunchViewController {
    func setupNavigationAppearance() {
        NavigationStyler.apply(style: .largeTitle, for: self, title: "Favourites")
    }
}

extension FavouriteLaunchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FavouriteLaunchCell.reuseID,
            for: indexPath
        ) as! FavouriteLaunchCell
        cell.selectionStyle = .none
        cell.configure(with: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let fav = items[indexPath.row]

        guard let id = fav.id else { return }
        let detailVC = LaunchDetailViewController(id: id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension FavouriteLaunchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(searchText)
    }
}

// MARK: - UITextFieldDelegate
extension FavouriteLaunchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
