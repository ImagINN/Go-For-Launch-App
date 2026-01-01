//
//  DateFormatter.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 11.10.2025.
//

import Foundation

public let customDateFormatter: DateFormatter = { //TODO: İhtiyaç olmazsa silinir.
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .short
    return df
}()
