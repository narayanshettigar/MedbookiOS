//
//  NetworkServiceProtocol.swift
//  MedBook
//
//  Created by Narayan Shettigar on 14/11/24.
//


import Foundation
import SwiftData

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
