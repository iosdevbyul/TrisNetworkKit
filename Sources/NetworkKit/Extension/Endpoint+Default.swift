//
//  Endpoint+Default.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-12.
//

import Foundation

public extension Endpoint {
    
    var headers: [String: String] {
        [:]
    }
    
    var queryItems: [URLQueryItem] {
        []
    }
    
    var body: Data? {
        nil
    }
}
