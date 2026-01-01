//
//  LaunchRepository.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation
import GoForLaunchAPI

protocol LaunchRepositoryProtocol {
    func fetchLaunches(
        scope: LaunchStatusFilter,
        limit: Int,
        offset: Int,
        completion: @escaping (Result<(items: [Launch], nextOffset: Int?), ErrorHandler>) -> Void
    )
}

final class LaunchRepository: LaunchRepositoryProtocol {

    private let service: LaunchServiceProtocol
    
    init(service: LaunchServiceProtocol = LaunchService()) {
        self.service = service
    }
    
    func fetchLaunches(
        scope: LaunchStatusFilter,
        limit: Int,
        offset: Int,
        completion: @escaping (Result<(items: [Launch], nextOffset: Int?), ErrorHandler>) -> Void
    ) {
        Task {
            do {
                let page = try await service.fetchList(
                    scope: scope.toAPIScope(),
                    limit: limit,
                    offset: offset
                )
                
                let mapped = page.results.map { dto in
                    Launch(
                        id: dto.id,
                        name: dto.name,
                        dateUTC: dto.net,
                        url: dto.url,
                        statusName: dto.statusName,
                        statusDescription: dto.statusDescription,
                        thumbnailURL: dto.thumbnailURL
                    )
                }
                
                let next = extractOffset(from: page.next)
                completion(.success((mapped, next)))
            } catch {
                if let apiError = error as? ErrorHandler {
                    completion(.failure(apiError))
                } else {
                    completion(.failure(.network(error)))
                }
            }
        }
    }

    private func extractOffset(from nextURL: String?) -> Int? {
        guard
            let nextURL,
            let components = URLComponents(string: nextURL),
            let value = components.queryItems?.first(where: { $0.name == "offset" })?.value,
            let next = Int(value)
        else { return nil }
        
        return next
    }
}

private extension LaunchStatusFilter {
    func toAPIScope() -> ListScope {
        switch self {
        case .upcoming: return .upcoming
        case .previous: return .previous
        case .all: return .all
        }
    }
}
