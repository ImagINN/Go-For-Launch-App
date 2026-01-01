//
//  Endpoint.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation

public enum ListScope: String {
    case all = "launches", previous = "launches/previous", upcoming = "launches/upcoming"
}

public enum EndpointHandler {
    static let base = URL(string: "https://ll.thespacedevs.com/2.3.0/")!

    case list(scope: ListScope, limit: Int = 10, offset: Int = 0)
    case detail(id: String)

    var url: URL {
        switch self {
        case let .list(scope, limit, offset):
            var components = URLComponents(url: Self.base.appendingPathComponent(scope.rawValue), resolvingAgainstBaseURL: false)!
            components.queryItems = [
                .init(name: "limit", value: "\(limit)"),
                .init(name: "mode",  value: "list"),
                .init(name: "offset", value: "\(offset)")
            ]
            print("URL: \(String(describing: components.url))")
            return components.url! //TODO: Force iyi mi kötü mü
        case let .detail(id):
            return Self.base.appendingPathComponent("launches/\(id)/")
        }
    }
}
