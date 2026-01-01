//
//  LaunchDetailViewController.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 12.10.2025.
//

import UIKit
import GoForLaunchAPI

final class LaunchDetailViewController: UIViewController {
    
    private var launchDetailViewModel: LaunchDetailViewModelProtocol
    
    private let favouritesRepo = FavouritesRepository(ctx: CoreDataStack.shared.viewContext)
    private var currentDetail: LaunchDetail?
    private var isFaved: Bool = false { didSet { updateFavButtonIcon() } }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerStack = UIStackView()
    
    private let headerView = HeaderView()
    private let countdownView = CountdownView()
    private let launchServiceProviderView = LaunchServiceProviderView()
    private let rocketView = RocketView()
    private let missionView = MissionView()
    private let programView = ProgramView()
    
    private lazy var favoriteButton: UIBarButtonItem = {
        let b = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteTapped)
        )
        b.tintColor = AppColors.accent
        return b
    }()
    
    init(id: String, viewModel: LaunchDetailViewModelProtocol? = nil) {
        if let vm = viewModel {
            self.launchDetailViewModel = vm
        } else {
            self.launchDetailViewModel = LaunchDetailViewModel(id: id)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationAppearance()
        configuration()
        bindViewModel()
        launchDetailViewModel.load()
    }
    
}

extension LaunchDetailViewController: ViewBuilderProtocol {
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func buildHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(containerStack)
        
        [
            headerView,
            countdownView,
            launchServiceProviderView,
            rocketView,
            missionView,
            programView
        ].forEach(containerStack.addArrangedSubview(_:))
    }
    
    func setupStyles() {
        view.backgroundColor = AppColors.background
        
        scrollView.showsVerticalScrollIndicator = false
        
        containerStack.axis = .vertical
        containerStack.spacing = ViewMetrics.viewElementSpacing
    }
    
    func setupConstraints() {
        [
            scrollView,
            contentView,
            containerStack,
            headerView
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            containerStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
        ])
    }
}

private extension LaunchDetailViewController {
    func bindViewModel() {
        launchDetailViewModel.onLoading = { [weak self] isLoading in
            guard let self else { return }
            isLoading ? self.showLoadingView() : self.hideLoadingView()
        }
        launchDetailViewModel.onDetail = { [weak self] detail in
            guard let self else { return }

            self.currentDetail = detail
            if let id = detail.id {
                self.isFaved = (try? self.favouritesRepo.isFavourite(id: id)) ?? false
            }

            self.headerView.configure(with: detail)
            self.countdownView.startCountdown(to: detail.net)
            self.launchServiceProviderView.configure(with: detail)
            self.rocketView.configure(with: detail)
            self.missionView.configure(with: detail)
            self.programView.configure(with: detail)
        }
        
        launchDetailViewModel.onError = { [weak self] error in
            self?.showError(title: "Error", message: error.localizedDescription)
        }
    }
}

private extension LaunchDetailViewController {
    func setupNavigationAppearance() {
        NavigationStyler.apply(style: .standard, for: self, title: "Launch Detail")
        navigationItem.rightBarButtonItem = favoriteButton
        updateFavButtonIcon()
    }

    func updateFavButtonIcon() {
        favoriteButton.image = UIImage(systemName: isFaved ? "heart.fill" : "heart")
        favoriteButton.accessibilityLabel = isFaved ? "Favoriden kaldır" : "Favorilere ekle"
    }
    
    @objc func favoriteTapped() {
        guard let detail = currentDetail, let id = detail.id else { return }
        
        do {
            if isFaved {
                try favouritesRepo.remove(id: id)
                isFaved = false
            } else {
                try favouritesRepo.add(detail.asFavourite)
                isFaved = true
            }
        } catch {
            showError(title: "Hata", message: error.localizedDescription)
        }
    }
}

private extension LaunchDetail {
    var asFavourite: FavouriteLaunch {
        FavouriteLaunch(
            id: id,
            name: name,
            statusName: statusName,
            dateUTC: net,
            thumbnailURL: imageURL
        )
    }
}
