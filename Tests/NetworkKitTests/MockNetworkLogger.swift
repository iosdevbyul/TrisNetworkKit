//
//  MockNetworkLogger.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-22.
//

import Foundation
@testable import NetworkKit

final class MockNetworkLogger: NetworkLogger {

    private(set) var events: [NetworkLogEvent] = []

    func log(_ event: NetworkLogEvent) {
        events.append(event)
    }
}
