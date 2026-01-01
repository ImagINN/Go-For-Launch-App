//
//  LaunchDetailViewModel.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import Foundation
import GoForLaunchAPI

protocol LaunchDetailViewModelProtocol {
    var onLoading: ((Bool) -> Void)? { get set }
    var onDetail: ((LaunchDetail) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    func load()
}

final class LaunchDetailViewModel: LaunchDetailViewModelProtocol {
    private let id: String
    private let service: LaunchServiceProtocol
    
    init(id: String, service: LaunchServiceProtocol = LaunchService()) {
        self.id = id
        self.service = service
    }
    
    // Outputs
    var onLoading: ((Bool) -> Void)?
    var onDetail: ((LaunchDetail) -> Void)?
    var onError: ((Error) -> Void)?
    
    func load() {
        Task {
            await MainActor.run { self.onLoading?(true) }

            do {
                let detail = try await service.fetchDetail(id: id)

                await MainActor.run { self.onDetail?(detail) }
            } catch {
                await MainActor.run { self.onError?(error) }
            }

            await MainActor.run { self.onLoading?(false) }
        }
    }
}
