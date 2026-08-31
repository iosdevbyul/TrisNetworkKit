//
//  MockAccessTokenProvider.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-09-01.
//

@testable import NetworkKit

final class MockAccessTokenProvider: AccessTokenProvider, @unchecked Sendable {

    var accessToken: String?

    init(accessToken: String?) {
        self.accessToken = accessToken
    }
}
