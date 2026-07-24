//
//  AuthorizationRequestInterceptor.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-24.
//

import Foundation

public struct AuthorizationRequestInterceptor: RequestInterceptor {

    private let token: String

    public init(token: String) {
        self.token = token
    }

    public func intercept(
        _ request: URLRequest
    ) async throws -> URLRequest {

        var request = request

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }
}
