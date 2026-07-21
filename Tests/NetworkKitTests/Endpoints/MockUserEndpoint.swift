//
//  MockUserEndpoint.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-21.
//

import Foundation
@testable import NetworkKit

enum MockUserEndpoint: Endpoint {
    case user

    var path: String {
        "/users/1"
    }

    var method: HTTPMethod {
        .get
    }
}
