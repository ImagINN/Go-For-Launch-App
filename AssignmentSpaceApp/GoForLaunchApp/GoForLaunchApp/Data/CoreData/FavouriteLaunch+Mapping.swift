//
//  FavouriteLaunch+Mapping.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import CoreData

extension FavouriteLaunchEntity {
    func toDomain() -> FavouriteLaunch {
        .init(
            id: self.id,
            name: self.name,
            statusName: self.statusName,
            dateUTC: self.dateUTC,
            thumbnailURL: self.thumbnailURL
        )
    }

    func fill(from fav: FavouriteLaunch) {
        if let id = fav.id { self.id = id }
        self.name = fav.name
        self.statusName = fav.statusName
        self.dateUTC = fav.dateUTC
        self.thumbnailURL = fav.thumbnailURL
    }
}
