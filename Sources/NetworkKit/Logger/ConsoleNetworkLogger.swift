//
//  ConsoleNetworkLogger.swift
//  NetworkKit
//
//  Created by COMATOKI on 2026-07-13.
//

import Foundation

public struct ConsoleNetworkLogger: NetworkLogger {

    public init() { }

    public func log(_ event: NetworkLogEvent) {
        let message: String

        switch event {

        case .request(let request):
            message = makeRequestLog(request)

        case let .response(request, response, data):
            message = makeResponseLog(
                request: request,
                response: response,
                data: data
            )

        case let .transportError(request, error):
            message = makeTransportErrorLog(
                request: request,
                error: error
            )
        }

        print(message)
    }
}

private extension ConsoleNetworkLogger {

    func makeRequestLog(_ request: URLRequest) -> String {

        var log = "[Request]\n"

        log += "URL: \(request.url?.absoluteString ?? "Unknown")\n"
        log += "Method: \(request.httpMethod ?? "Unknown")\n"

        log += "\nHeaders:\n"

        if let headers = request.allHTTPHeaderFields,
           !headers.isEmpty {

            headers.forEach {
                log += "\($0.key): \($0.value)\n"
            }

        } else {
            log += "None\n"
        }

        log += "\nBody:\n"

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {

            log += bodyString

        } else {
            log += "None"
        }

        return log
    }

    func makeResponseLog(
        request: URLRequest,
        response: HTTPURLResponse,
        data: Data
    ) -> String {

        var log = "[Response]\n"

        log += "URL: \(request.url?.absoluteString ?? "Unknown")\n"
        log += "Method: \(request.httpMethod ?? "Unknown")\n"
        log += "Status Code: \(response.statusCode)\n"

        log += "\nHeaders:\n"

        if !response.allHeaderFields.isEmpty {
            response.allHeaderFields.forEach {
                log += "\($0.key): \($0.value)\n"
            }
        } else {
            log += "None\n"
        }

        log += "\nBody:\n"

        if let body = String(data: data, encoding: .utf8),
           !body.isEmpty {
            log += body
        } else {
            log += "None"
        }

        return log
    }

    func makeTransportErrorLog(
        request: URLRequest?,
        error: Error
    ) -> String {

        var log = "[Transport Error]\n"

        log += "URL: \(request?.url?.absoluteString ?? "Unknown")\n"

        log += "\nError:\n"
        log += error.localizedDescription

        return log
    }
}
