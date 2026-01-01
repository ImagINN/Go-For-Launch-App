//
//  LaunchService.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation

public protocol LaunchServiceProtocol {
    func fetchList(scope: ListScope, limit: Int, offset: Int) async throws -> LaunchListResponse
    func fetchDetail(id: String) async throws -> LaunchDetailResponse
}

public final class LaunchService: LaunchServiceProtocol {
    private let client: HTTPClientProtocol
    private let decoder: JSONDecoder

    public init(client: HTTPClientProtocol = HTTPClient(), decoder: JSONDecoder = Decoders.default) {
        self.client = client
        self.decoder = decoder
    }

    public func fetchList(
        scope: ListScope,
        limit: Int = 10,
        offset: Int = 0
    ) async throws -> LaunchListResponse {
        try await client.get(
            EndpointHandler.list(
                scope: scope,
                limit: limit,
                offset: offset
            ).url,
            decoder: decoder
        )
    }

    public func fetchDetail(id: String) async throws -> LaunchDetailResponse {
        try await client.get(EndpointHandler.detail(id: id).url, decoder: decoder)
    }
}
