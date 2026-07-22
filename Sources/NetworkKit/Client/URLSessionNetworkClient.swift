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
    private let logger: any NetworkLogger
    private let decoder = JSONDecoder()
    private let interceptor: any RequestInterceptor
    
    public init(
        configuration: NetworkConfiguration,
        session: URLSession = .shared,
        logger: any NetworkLogger = NoOpNetworkLogger(),
        interceptor: any RequestInterceptor = NoOpRequestInterceptor()
    ) {
        self.configuration = configuration
        self.session = session
        self.logger = logger
        self.interceptor = interceptor
    }
    
    public func request<T: Decodable>(
        endpoint: any Endpoint,
        responseType: T.Type
    ) async throws -> T {

        var request = try makeRequest(
            from: endpoint
        )

        request = try await interceptor.intercept(
            request
        )

        logger.log(
            .request(
                request: request
            )
        )

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logger.log(
                .transportError(
                    request: request,
                    error: error
                )
            )

            throw NetworkError.unknown(error)
        }

        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        logger.log(
            .response(
                request: request,
                response: response,
                data: data
            )
        )

        guard 200...299 ~= response.statusCode else {
            throw NetworkError.serverError(response.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
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
