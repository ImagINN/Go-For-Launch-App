//
//  LaunchListViewModel.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation

protocol LaunchListViewModelProtocol {
    // Inputs
    func load()
    func apply(status: LaunchStatusFilter)
    func search(query: String)
    func didSelectItem(at index: Int)
    
    // Outputs
    var onItemsChanged: (([Launch]) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onPaging: ((Bool) -> Void)? { get set }
    var onNavigateDetail: ((String) -> Void)? { get set }
}

final class LaunchListViewModel: LaunchListViewModelProtocol {
    private let repository: LaunchRepositoryProtocol
    
    private var all: [Launch] = []
    private var filtered: [Launch] = []
    private var query = LaunchListQuery()
    private var searchDebounce: Timer?
    
    private let limit = 10
    private var currentOffset = 0
    private var nextOffset: Int? = 0
    private var isLoading = false
    private var pendingStatus: LaunchStatusFilter?
    
    // outputs
    var onItemsChanged: (([Launch]) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onPaging: ((Bool) -> Void)?
    var onNavigateDetail: ((String) -> Void)?
    
    init(repository: LaunchRepositoryProtocol) {
        self.repository = repository
    }
    
    // inputs
    func load() { fetch(reset: true) }
    
    func apply(status: LaunchStatusFilter) {
        
        if isLoading {
            pendingStatus = status
            return
        }
        
        guard query.status != status else { return }
        
        query.status = status
        fetch(reset: true)
    }

    func search(query: String) {
        searchDebounce?.invalidate()
        searchDebounce = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.query.search = query
            self.applyFiltersAndEmit()
        }
    }
    
    func didSelectItem(at index: Int) {
        guard index >= 0 && index < filtered.count else {
            onError?("Invalid selection index.")
            return
        }
        let launch = filtered[index]
        guard let id = launch.id, !id.isEmpty else {
            onError?("Launch id not found.")
            return
        }
        onNavigateDetail?(id)
    }
    
    // MARK: - Networking
    private func fetch(reset: Bool) {
        guard !isLoading else { return }
        isLoading = true

        if reset {
            onLoading?(true)
            currentOffset = 0
            nextOffset = 0
            all.removeAll()
        } else {
            onPaging?(true)
        }

        let requestedOffset = currentOffset
        
        print("Fetching status= \(query.status), limit= \(limit), offset= \(requestedOffset)")
        
        repository.fetchLaunches(
            scope: query.status,
            limit: limit,
            offset: requestedOffset
        ) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if reset {
                    self.onLoading?(false)
                } else {
                    self.onPaging?(false)
                }
                
                switch result {
                case let .success(page):
                    self.all += page.items
                    self.nextOffset = page.nextOffset
                    self.currentOffset = page.nextOffset ?? requestedOffset
                    self.applyFiltersAndEmit()
                    
                    if let next = self.pendingStatus, next != self.query.status {
                        self.pendingStatus = nil
                        self.apply(status: next)
                    } else {
                        self.pendingStatus = nil
                    }

                case let .failure(error):
                    let message = (error as LocalizedError).errorDescription
                    self.onError?(message ?? AppStrings.defaultErrorMessage)
                    self.onItemsChanged?([])
                    self.pendingStatus = nil
                }
            }
        }
    }

    func loadNextPageIfNeeded(_ index: Int) {
        guard index >= filtered.count - 5 else { return }
        
        guard let next = nextOffset else { return }
        
        currentOffset = next
        fetch(reset: false)
    }

    private func applyFiltersAndEmit() {
        filtered = all
            .filter { launch in
                guard !query.search.isEmpty else { return true }
                return launch.name?.localizedCaseInsensitiveContains(query.search) == true
            }
        
        if Thread.isMainThread {
            onItemsChanged?(filtered)
        } else {
            DispatchQueue.main.async { [weak self] in self?.onItemsChanged?(self?.filtered ?? []) }
        }
    }
}
