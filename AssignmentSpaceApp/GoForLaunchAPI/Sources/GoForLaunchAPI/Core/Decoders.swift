//
//  Decoders.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation

public enum Decoders {
    public static var `default`: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        
        jsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)

            let firstFormatter = ISO8601DateFormatter()
            firstFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let dt = firstFormatter.date(from: str) {
                return dt
            }

            let secondFormatter = ISO8601DateFormatter()
            secondFormatter.formatOptions = [.withInternetDateTime]
            if let dateTime = secondFormatter.date(from: str) {
                return dateTime
            }

            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Invalid ISO8601 date: \(str)"
            ))
        }
        
        return jsonDecoder
    }
}
