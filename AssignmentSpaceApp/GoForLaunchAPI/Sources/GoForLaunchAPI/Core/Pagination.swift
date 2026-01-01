//
//  Pagination.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation

public struct Page<T: Decodable>: Decodable {
    public let count: Int?
    public let next: String?
    public let previous: String?
    public let results: [T]

    public enum CodingKeys: String, CodingKey {
        case count, next, previous, results
    }
}

