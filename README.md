# NetworkKit

A lightweight and extensible networking layer for iOS applications.

NetworkKit provides a protocol-based networking abstraction built on top of
`URLSession`, with support for endpoint abstraction, request interception,
authorization headers, logging, configuration, and dependency injection.

The goal is to keep networking infrastructure independent from application
features while making the implementation easy to test and replace.

## Requirements

- iOS 13+
- Swift 6.3+
- Xcode 16+

## Features

- `URLSession` based networking
- Protocol-oriented network client
- Endpoint abstraction
- HTTP method abstraction
- Centralized network configuration
- Typed network errors
- Request interception
- Authorization header injection
- Network request/response logging
- Dependency injection
- `URLProtocol` based network testing
- Swift 6 language mode

## Architecture

NetworkKit separates networking concerns through protocols and concrete
implementations.

```text
┌─────────────────────────────┐
│        Application          │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│        NetworkClient        │
│         (Protocol)          │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   URLSessionNetworkClient   │
└───────┬─────────┬───────────┘
        │         │
        │         └──────────────────┐
        ▼                            ▼
┌───────────────┐          ┌────────────────────┐
│    Endpoint   │          │ RequestInterceptor │
└───────────────┘          └────────────────────┘
                                    │
                                    ▼
                           ┌────────────────────┐
                           │ Authorization      │
                           │ Interceptor        │
                           └────────────────────┘

        ┌────────────────────┐
        │   NetworkLogger    │
        └────────────────────┘
```

The application depends on the `NetworkClient` protocol rather than directly
depending on `URLSession`.

This makes the networking layer replaceable and easier to test.

## Installation

NetworkKit is distributed as a Swift Package.

### Swift Package Manager

Add NetworkKit as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/iosdevbyul/TrisNetworkKit.git",
        from: "1.0.0"
    )
]
```

Then add `NetworkKit` to your target dependencies:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(
            name: "NetworkKit",
            package: "TrisNetworkKit"
        )
    ]
)
```

## Basic Usage

### 1. Define an Endpoint

Create an endpoint that conforms to `Endpoint`.

```swift
import Foundation
import NetworkKit

struct UserEndpoint: Endpoint {
    let path = "/users"
    let method: HTTPMethod = .get

    var headers: [String: String] {
        [
            "Content-Type": "application/json"
        ]
    }

    var queryItems: [URLQueryItem] {
        []
    }

    var body: Data? {
        nil
    }
}
```

### 2. Create Network Configuration

```swift
import NetworkKit

let configuration = NetworkConfiguration(
    baseURL: URL(string: "https://api.example.com")!
)
```

You can also configure the request timeout:

```swift
let configuration = NetworkConfiguration(
    baseURL: URL(string: "https://api.example.com")!,
    timeout: 60
)
```

### 3. Create a Network Client

```swift
let networkClient = URLSessionNetworkClient(
    configuration: configuration
)
```

### 4. Make a Request

Define a response model:

```swift
struct User: Decodable {
    let id: String
    let name: String
}
```

Then request it through `NetworkClient`:

```swift
let user: User = try await networkClient.request(
    endpoint: UserEndpoint(),
    responseType: User.self
)
```

## Endpoint

`Endpoint` describes everything required to build an HTTP request.

```swift
public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
}
```

This keeps request construction separate from the network client itself.

## Request Interceptor

`RequestInterceptor` allows requests to be modified before they are sent.

```swift
public protocol RequestInterceptor: Sendable {
    func intercept(
        _ request: URLRequest
    ) async throws -> URLRequest
}
```

### AuthorizationRequestInterceptor

`AuthorizationRequestInterceptor` injects an access token into the
`Authorization` header.

```swift
let interceptor = AuthorizationRequestInterceptor(
    tokenProvider: tokenProvider
)

let networkClient = URLSessionNetworkClient(
    configuration: configuration,
    interceptor: interceptor
)
```

The resulting request contains:

```text
Authorization: Bearer <access-token>
```

The token is provided through `AccessTokenProvider`:

```swift
public protocol AccessTokenProvider: Sendable {
    var accessToken: String? { get }
}
```

This keeps token management outside of NetworkKit.

## Logging

NetworkKit provides a protocol-based logging system.

```swift
public protocol NetworkLogger: Sendable {
    func log(_ event: NetworkLogEvent)
}
```

A logger can be injected into `URLSessionNetworkClient`:

```swift
let networkClient = URLSessionNetworkClient(
    configuration: configuration,
    logger: ConsoleNetworkLogger()
)
```

Logging can also be disabled by using the default `NoOpNetworkLogger`.

## Error Handling

Network failures are represented by `NetworkError`.

```swift
public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed(Error)
    case serverError(Int)
    case unknown(Error)
}
```

Example:

```swift
do {
    let user: User = try await networkClient.request(
        endpoint: UserEndpoint(),
        responseType: User.self
    )
} catch let error as NetworkError {
    switch error {
    case .invalidURL:
        print("Invalid URL")

    case .invalidResponse:
        print("Invalid response")

    case .decodingFailed(let error):
        print("Decoding failed:", error)

    case .serverError(let statusCode):
        print("Server error:", statusCode)

    case .unknown(let error):
        print("Unknown error:", error)
    }
}
```

## Dependency Injection

NetworkKit is designed around dependency injection.

The application can depend on:

```swift
any NetworkClient
```

instead of directly depending on:

```swift
URLSessionNetworkClient
```

This makes it possible to provide a mock implementation in tests.

```swift
struct MockNetworkClient: NetworkClient {

    func request<T: Decodable>(
        endpoint: any Endpoint,
        responseType: T.Type
    ) async throws -> T {
        // Return test data
    }
}
```

## Testing

NetworkKit uses `URLProtocol` to test `URLSession` request flows without making
real network requests.

The test suite covers:

- Successful response decoding
- HTTP server errors
- Decoding failures
- Transport errors
- Authorization header injection
- Network request logging
- Network response logging
- Transport error logging
- Request construction

## Project Structure

```text
Sources/
└── NetworkKit/
    ├── Client/
    │   └── URLSessionNetworkClient.swift
    ├── Configuration/
    │   └── NetworkConfiguration.swift
    ├── Error/
    │   └── NetworkError.swift
    ├── Extension/
    │   └── Endpoint+Default.swift
    ├── HTTP/
    │   └── HTTPMethod.swift
    ├── Interceptor/
    │   ├── AuthorizationRequestInterceptor.swift
    │   └── NoOpRequestInterceptor.swift
    ├── Logger/
    │   ├── ConsoleNetworkLogger.swift
    │   ├── NetworkLogEvent.swift
    │   ├── NetworkLogger.swift
    │   └── NoOpNetworkLogger.swift
    └── Protocols/
        ├── AccessTokenProvider.swift
        ├── Endpoint.swift
        ├── NetworkClient.swift
        └── RequestInterceptor.swift
```

## Design Goals

### Protocol-oriented

Networking responsibilities are defined through protocols so individual
components can be replaced independently.

### Dependency Injection

Concrete implementations such as `URLSessionNetworkClient`,
`NetworkLogger`, and `RequestInterceptor` are injected rather than tightly
coupled.

### Testability

Network requests can be tested without relying on real external APIs.

### Separation of Concerns

Endpoint definition, request execution, authentication, logging, and error
handling are separated into independent components.

### Minimal Dependencies

NetworkKit is built on Apple's `Foundation` and `URLSession` APIs without
requiring a third-party networking framework.

## License

MIT License
