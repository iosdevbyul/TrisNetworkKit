//
//  AuthorizationRequestInterceptor.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-24.
//

import Foundation

public struct AuthorizationRequestInterceptor: RequestInterceptor {

    private let tokenProvider: any AccessTokenProvider

    public init(
        tokenProvider: any AccessTokenProvider
    ) {
        self.tokenProvider = tokenProvider
    }

    public func intercept(
        _ request: URLRequest
    ) async throws -> URLRequest {

        guard let accessToken = tokenProvider.accessToken else {
            return request
        }

        var request = request

        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }
}
