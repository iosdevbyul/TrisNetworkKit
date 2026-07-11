//
//  NetworkClient.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-11.
//

import Foundation

public protocol NetworkClient {
    func request<T: Decodable>(
        endpoint: any Endpoint,
        responseType: T.Type
    ) async throws -> T
}
