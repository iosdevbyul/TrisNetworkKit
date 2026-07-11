//
//  URLSessionNetworkClient.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-12.
//

import Foundation

public final class URLSessionNetworkClient: NetworkClient {
    
    private let configuration: NetworkConfiguration
    private let session: URLSession
    
    public init(
        configuration: NetworkConfiguration,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }
    
    public func request<T: Decodable>(
        endpoint: any Endpoint,
        responseType: T.Type
    ) async throws -> T {

        let request = try makeRequest(from: endpoint)

        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200...299 ~= response.statusCode else {
            throw NetworkError.invalidStatusCode(response.statusCode)
        }

        fatalError("Next step")
    }
    
    // MARK: - Private
    private func makeRequest(
        from endpoint: any Endpoint
    ) throws -> URLRequest {

        var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )

        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = configuration.timeout
        endpoint.headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        request.httpBody = endpoint.body

        return request
    }
}
