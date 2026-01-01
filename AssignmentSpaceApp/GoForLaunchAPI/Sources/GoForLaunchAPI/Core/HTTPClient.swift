//
//  HTTPClient.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation
import Alamofire

public protocol HTTPClientProtocol {
    func get<T: Decodable>(_ url: URL, decoder: JSONDecoder) async throws -> T
}

public class HTTPClient: HTTPClientProtocol {
    
    private let session: Session
    
    public init(configuration: URLSessionConfiguration = .af.default) {
        self.session = Session(configuration: configuration)
    }
    
    public func get<T: Decodable>(_ url: URL, decoder: JSONDecoder) async throws -> T {
        try await withCheckedThrowingContinuation { cont in
            session.request(url, method: .get)
                .validate()
                .responseDecodable(of: T.self, decoder: decoder) { response in
                    switch response.result {
                    case .success(let value):
                        cont.resume(returning: value)
                    case .failure(let error):
                        let status = response.response?.statusCode
                        let headers = response.response.map {
                            HTTPHeaders($0.allHeaderFields as? [String: String] ?? [:])
                        }
                        cont.resume(
                            throwing: ErrorHandler.fromAF(
                                error,
                                data: response.data,
                                statusCode: status,
                                headers: headers
                            )
                        )
                    }
                }
        }
    }
}
