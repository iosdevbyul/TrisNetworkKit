//
//  NetworkError.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-11.
//

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed(Error)
    case serverError(_ statusCode: Int)
    case unknown(Error)
}
