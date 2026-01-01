//
//  LaunchSummary.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation

public struct LaunchSummary: Decodable {
    public let id: String
    public let url: String?
    public let name: String
    public let statusName: String?
    public let statusDescription: String?
    public let net: Date
    public let thumbnailURL: String?

    private enum CodingKeys: String, CodingKey {
        case id, url, name, status, net, image
    }

    private struct Status: Decodable {
        let name: String?
        let description: String?
    }

    private struct Image: Decodable {
        let thumbnail_url: String?
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        url = try? container.decode(String.self, forKey: .url)
        name = try container.decode(String.self, forKey: .name)
        net = try container.decode(Date.self, forKey: .net)

        if let status = try? container.decode(Status.self, forKey: .status) {
            statusName = status.name
            statusDescription = status.description
        } else {
            statusName = nil
            statusDescription = nil
        }

        if let img = try? container.decode(Image.self, forKey: .image) {
            thumbnailURL = img.thumbnail_url
        } else {
            thumbnailURL = nil
        }
    }
}
