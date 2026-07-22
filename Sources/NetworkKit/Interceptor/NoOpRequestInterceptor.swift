//
//  NoOpRequestInterceptor.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-22.
//

import Foundation

public struct NoOpRequestInterceptor: RequestInterceptor {

    public init() {
    }

    public func intercept(
        _ request: URLRequest
    ) async throws -> URLRequest {
        request
    }
}
