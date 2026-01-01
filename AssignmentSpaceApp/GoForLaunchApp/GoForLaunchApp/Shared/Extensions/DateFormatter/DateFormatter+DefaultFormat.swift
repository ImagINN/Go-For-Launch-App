//
//  DateFormatter+DefaultFormat.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 12.10.2025.
//

import Foundation

extension DateFormatter {
    static let defaultDateFormat: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
}
