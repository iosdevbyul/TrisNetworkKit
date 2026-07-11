//
//  Endpoint.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-11.
//

import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}
