//
//  RequestInterceptor.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-22.
//

import Foundation

public protocol RequestInterceptor {
    func intercept(
        _ request: URLRequest
    ) async throws -> URLRequest
}
