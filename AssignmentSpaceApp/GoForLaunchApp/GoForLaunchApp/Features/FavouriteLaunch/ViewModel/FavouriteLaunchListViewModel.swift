//
//  FavouriteLaunchListViewModel.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import Foundation

protocol FavouriteLaunchListViewModelProtocol {
    var onItemsChanged: (([FavouriteLaunch]) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    func load()
    func search(_ text: String)
}

final class FavouriteLaunchListViewModel: FavouriteLaunchListViewModelProtocol {
    private let repo: FavouritesRepositoryProtocol
    private var all: [FavouriteLaunch] = []
    private var filtered: [FavouriteLaunch] = []

    var onItemsChanged: (([FavouriteLaunch]) -> Void)?
    var onError: ((Error) -> Void)?

    init(repo: FavouritesRepositoryProtocol) {
        self.repo = repo
    }

    func load() {
        do {
            let items = try repo.all()
            self.all = items
            self.filtered = items
            onItemsChanged?(filtered)
        } catch {
            onError?(error)
        }
    }

    func search(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { filtered = all; onItemsChanged?(filtered); return }
        filtered = all.filter {
            ($0.name ?? "").localizedCaseInsensitiveContains(q) ||
            ($0.statusName ?? "").localizedCaseInsensitiveContains(q)
        }
        onItemsChanged?(filtered)
    }
}
