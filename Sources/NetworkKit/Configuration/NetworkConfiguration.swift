//
//  NetworkConfiguration.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-11.
//

import Foundation

public struct NetworkConfiguration {
    public let baseURL: URL
    public let timeout: TimeInterval

    public init(
        baseURL: URL,
        timeout: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.timeout = timeout
    }
}
