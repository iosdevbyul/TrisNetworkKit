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

        let logger = MockNetworkLogger()

        let client = URLSessionNetworkClient(
            configuration: networkConfiguration,
            session: session,
            logger: logger
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
        XCTAssertEqual(
            logger.events.count,
            2
        )
        
        if case .request = logger.events[0] {
            // Expected
        } else {
            XCTFail("Expected request log event.")
        }

        if case .response = logger.events[1] {
            // Expected
        } else {
            XCTFail("Expected response log event.")
        }
    }
    
    func test_request_whenResponseIs404_throwsServerError() async {

        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://example.com/users/1")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        MockURLProtocol.responseData = Data()
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
        
        let logger = MockNetworkLogger()
        let client = URLSessionNetworkClient(
            configuration: networkConfiguration,
            session: session,
            logger: logger
        )

        do {
            _ = try await client.request(
                endpoint: MockUserEndpoint.user,
                responseType: MockUser.self
            )

            XCTFail("Expected serverError, but request succeeded.")

        } catch let error as NetworkError {

            switch error {
            case .serverError(let statusCode):
                XCTAssertEqual(statusCode, 404)

            default:
                XCTFail(
                    "Expected serverError, but received \(error)"
                )
            }

        } catch {
            XCTFail(
                "Expected NetworkError.serverError, but received \(error)"
            )
        }
        
        XCTAssertEqual(
            logger.events.count,
            2
        )
        
        if case .request = logger.events[0] {
            // Expected
        } else {
            XCTFail("Expected request log event.")
        }

        if case .response = logger.events[1] {
            // Expected
        } else {
            XCTFail("Expected response log event.")
        }
    }
    
    func test_request_whenResponseDataIsInvalid_throwsDecodingFailed() async {

        let invalidResponseData = """
        {
            "id": "invalid",
            "name": 123
        }
        """.data(using: .utf8)!

        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://example.com/users/1")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        MockURLProtocol.responseData = invalidResponseData
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

        let logger = MockNetworkLogger()

        let client = URLSessionNetworkClient(
            configuration: networkConfiguration,
            session: session,
            logger: logger
        )

        do {
            _ = try await client.request(
                endpoint: MockUserEndpoint.user,
                responseType: MockUser.self
            )

            XCTFail(
                "Expected decodingFailed, but request succeeded."
            )

        } catch let error as NetworkError {

            switch error {
            case .decodingFailed:
                break

            default:
                XCTFail(
                    "Expected decodingFailed, but received \(error)"
                )
            }

        } catch {
            XCTFail(
                "Expected NetworkError.decodingFailed, but received \(error)"
            )
        }

        XCTAssertEqual(
            logger.events.count,
            2
        )

        if case .request = logger.events[0] {
            // Expected
        } else {
            XCTFail(
                "Expected request log event."
            )
        }

        if case .response = logger.events[1] {
            // Expected
        } else {
            XCTFail(
                "Expected response log event."
            )
        }
    }
    
    func test_request_whenTransportFails_throwsUnknownError() async {

        let expectedError = URLError(
            .notConnectedToInternet
        )

        MockURLProtocol.response = nil
        MockURLProtocol.responseData = nil
        MockURLProtocol.error = expectedError

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
        
        let logger = MockNetworkLogger()
        let client = URLSessionNetworkClient(
            configuration: networkConfiguration,
            session: session,
            logger: logger
        )

        do {
            _ = try await client.request(
                endpoint: MockUserEndpoint.user,
                responseType: MockUser.self
            )

            XCTFail(
                "Expected unknown error, but request succeeded."
            )

        } catch let error as NetworkError {

            switch error {
            case .unknown(let underlyingError):

                let urlError = underlyingError as? URLError

                XCTAssertEqual(
                    urlError?.code,
                    .notConnectedToInternet
                )

            default:
                XCTFail(
                    "Expected unknown error, but received \(error)"
                )
            }

        } catch {
            XCTFail(
                "Expected NetworkError.unknown, but received \(error)"
            )
        }
        
        XCTAssertEqual(
            logger.events.count,
            2
        )
        
        if case .request = logger.events[0] {
            // Expected
        } else {
            XCTFail("Expected request log event.")
        }
        
        if case .transportError = logger.events[1] {
            // Expected
        } else {
            XCTFail("Expected transportError log event.")
        }
    }
}

