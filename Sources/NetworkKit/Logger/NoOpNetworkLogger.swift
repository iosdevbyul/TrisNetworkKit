//
//  NoOpNetworkLogger.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-13.
//

public struct NoOpNetworkLogger: NetworkLogger {

    public init() { }

    public func log(_ event: NetworkLogEvent) {
        // Intentionally left blank.
    }
}
