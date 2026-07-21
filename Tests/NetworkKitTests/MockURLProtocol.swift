//
//  MockURLProtocol.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-21.
//

import Foundation

final class MockURLProtocol: URLProtocol {

    nonisolated(unsafe) static var response: HTTPURLResponse?
    nonisolated(unsafe) static var responseData: Data?
    nonisolated(unsafe) static var error: Error?

    override class func canInit(
        with request: URLRequest
    ) -> Bool {
        true
    }

    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }
    
    static func reset() {
        response = nil
        responseData = nil
        error = nil
    }

    override func startLoading() {

        if let error = Self.error {
            client?.urlProtocol(
                self,
                didFailWithError: error
            )
            return
        }

        guard let response = Self.response else {
            return
        }

        client?.urlProtocol(
            self,
            didReceive: response,
            cacheStoragePolicy: .notAllowed
        )

        if let data = Self.responseData {
            client?.urlProtocol(
                self,
                didLoad: data
            )
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}
