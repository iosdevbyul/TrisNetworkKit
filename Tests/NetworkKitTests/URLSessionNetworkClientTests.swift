//
//  URLSessionNetworkClientTests.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-21.
//

import XCTest
@testable import NetworkKit

final class URLSessionNetworkClientTests: XCTestCase {

    func test_request_whenResponseIs200_returnsDecodedModel() async throws {

        let responseData = """
        {
            "id": 1,
            "name": "Tris"
        }
        """.data(using: .utf8)!

        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://example.com/users/1")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        MockURLProtocol.responseData = responseData
        MockURLProtocol.error = nil

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [
            MockURLProtocol.self
        ]

        let session = URLSession(
            configuration: configuration
        )

        let networkConfiguration = NetworkConfiguration(
            baseURL: URL(string: "https://example.com")!
        )

        let client = URLSessionNetworkClient(
            configuration: networkConfiguration,
            session: session
        )

        let user = try await client.request(
            endpoint: MockUserEndpoint.user,
            responseType: MockUser.self
        )

        XCTAssertEqual(
            user,
            MockUser(
                id: 1,
                name: "Tris"
            )
        )
    }
}
