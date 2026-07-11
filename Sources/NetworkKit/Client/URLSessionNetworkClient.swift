//
//  URLSessionNetworkClient.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-12.
//

import Foundation

public final class URLSessionNetworkClient: NetworkClient {

    private let configuration: NetworkConfiguration
    private let session: URLSession

    public init(
        configuration: NetworkConfiguration,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }
}
