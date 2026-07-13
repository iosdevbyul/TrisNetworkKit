//
//  NetworkLogEvent.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-13.
//

import Foundation

public enum NetworkLogEvent {

    case request(request: URLRequest)

    case response(
        request: URLRequest,
        response: HTTPURLResponse,
        data: Data
    )

    case transportError(
        request: URLRequest?,
        error: Error
    )
}
