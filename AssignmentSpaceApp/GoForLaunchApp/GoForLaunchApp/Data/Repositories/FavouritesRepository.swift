//
//  FavouritesRepository.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import CoreData

public protocol FavouritesRepositoryProtocol {
    func add(_ fav: FavouriteLaunch) throws
    func remove(id: String) throws
    func isFavourite(id: String) throws -> Bool
    func all() throws -> [FavouriteLaunch]
}

public final class FavouritesRepository: FavouritesRepositoryProtocol {
    private let ctx: NSManagedObjectContext

    public init(ctx: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.ctx = ctx
    }

    public func add(_ fav: FavouriteLaunch) throws {
        guard let id = fav.id else { return }
        let entity = try find(by: id) ?? FavouriteLaunchEntity(context: ctx)
        entity.fill(from: fav)
        try ctx.save()
    }

    public func remove(id: String) throws {
        if let e = try find(by: id) {
            ctx.delete(e)
            try ctx.save()
        }
    }

    public func isFavourite(id: String) throws -> Bool {
        try find(by: id) != nil
    }

    public func all() throws -> [FavouriteLaunch] {
        let req = NSFetchRequest<FavouriteLaunchEntity>(entityName: "FavouriteLaunchEntity")
        req.sortDescriptors = [NSSortDescriptor(key: "dateUTC", ascending: false)]
        return try ctx.fetch(req).map { $0.toDomain() }
    }

    private func find(by id: String) throws -> FavouriteLaunchEntity? {
        let req = NSFetchRequest<FavouriteLaunchEntity>(entityName: "FavouriteLaunchEntity")
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "id == %@", id)
        return try ctx.fetch(req).first
    }
}
