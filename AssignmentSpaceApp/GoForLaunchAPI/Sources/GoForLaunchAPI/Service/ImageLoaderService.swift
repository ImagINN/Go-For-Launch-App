//
//  ImageLoaderService.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 11.10.2025.
//

import UIKit

public protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async throws -> UIImage
}

public final class ImageLoaderService: ImageLoaderProtocol {
    
    private let cache = NSCache<NSURL, UIImage>()
    
    public init() { }
    
    public func loadImage(from url: URL) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw ErrorHandler.invalidImageData
        }
        
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
