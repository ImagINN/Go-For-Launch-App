//
//  ErrorHandler.swift
//  GoForLaunchAPI
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation
import Alamofire

public enum ErrorHandler: Error {
    case network(Error)
    case decoding(Error)
    case server(status: Int, message: String?)
    case rateLimited(message: String?, retryAfter: TimeInterval?)
    case invalidImageData
    case unknown
    
    /*static func fromAF(_ error: AFError, data: Data?) -> ErrorHandler {
        if let code = error.responseCode {
            return .server(status: code, message: data.flatMap { String(data: $0, encoding: .utf8)})
        }
        
        if case let .responseSerializationFailed(reason) = error,
           case let .decodingFailed(inner) = reason { return .decoding(inner) }
        
        return .network(error)
    }*/
}

// MARK: - Localized Messages
extension ErrorHandler: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .rateLimited(let message, let retry):
            if let msg = message { return msg }
            if let r = retry { return "Rate limit exceeded. Try again in \(Int(r)) seconds." }
            return "Rate limit exceeded. Please try again later."
            
        case .server(let status, _):
            switch status {
            case 500...599: return "Server error occurred. Please try again later."
            case 401, 403: return "Unauthorized access. Please check your credentials."
            case 404: return "Requested resource not found."
            default: return "Unexpected server error."
            }
            
        case .network:
            return "Network connection issue. Please check your internet connection."
            
        case .decoding:
            return "Failed to parse server response."
            
        case .invalidImageData:
            return "Invalid image data."
            
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: Alamofire Error Helper Function
public extension ErrorHandler {
    static func fromAF(_ error: AFError,
                       data: Data?,
                       statusCode: Int?,
                       headers: HTTPHeaders?) -> ErrorHandler {
        
        if statusCode == 429 {
            var retryAfter: TimeInterval? = nil
            if let value = headers?["Retry-After"], let seconds = TimeInterval(value) {
                retryAfter = seconds
            }
            
            var message: String? = nil
            if let data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String {
                message = detail
            }
            
            return .rateLimited(message: message, retryAfter: retryAfter)
        }
        
        if let code = statusCode {
            let msg = data.flatMap { String(data: $0, encoding: .utf8) }
            return .server(status: code, message: msg)
        }
        
        if case let .responseSerializationFailed(reason) = error,
           case let .decodingFailed(inner) = reason {
            return .decoding(inner)
        }
        
        return .network(error)
    }
}
