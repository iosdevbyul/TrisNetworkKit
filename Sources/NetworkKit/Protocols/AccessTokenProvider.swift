//
//  AccessTokenProvider.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-08-31.
//

import Foundation

public protocol AccessTokenProvider: Sendable {

    var accessToken: String? { get }
}
