/*
 * MIT No Attribution
 *
 * Copyright 2025 Peter "Kevin" Contreras
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public final class ListeningRoomXPCDispatcher: NSObject, Sendable {
    public enum Role: String, Sendable {
        case placeholder
        case extensionMain
        case extensionScene
        case hostMain
        case hostView
    }
    
    public init(role: Role, endpoints: [any ListeningRoomXPCEndpoint]) {
        var endpointsByName = [String: any ListeningRoomXPCEndpoint]()
        func name<Endpoint: ListeningRoomXPCEndpoint>(of endpoint: Endpoint) -> String {
            Endpoint.Request.endpoint
        }
        for endpoint in endpoints {
            endpointsByName[name(of: endpoint)] = endpoint
        }
        self.role = role
        self.endpointsByName = endpointsByName
    }
    
    private let role: Role
    private let endpointsByName: [String: any ListeningRoomXPCEndpoint]
    
    override public var description: String {
        "ListeningRoomXPCDispatcher(role: \(role), endpoints: [\(endpointsByName.keys.joined(separator: ", "))])"
    }
}

@objc(_ListeningRoomXPCDispatcher) internal protocol ListeningRoomXPCDispatcherProtocol: NSObjectProtocol {
    func _dispatch(_ request: Data,
                   to endpoint: String,
                   replyHandler: @escaping @Sendable (Data?, (any Error)?) -> Void) -> Void
}

extension ListeningRoomXPCDispatcher: ListeningRoomXPCDispatcherProtocol {
    internal func _dispatch(_ request: Data,
                            to endpoint: String,
                            replyHandler: @escaping @Sendable (Data?, (any Error)?) -> Void) {
        Task {
            do {
                guard let endpoint = endpointsByName[endpoint] else {
                    throw CocoaError(.featureUnsupported, userInfo: [
                        NSLocalizedDescriptionKey: "No <\(endpoint)> endpoint found",
                    ])
                }
                func call<Endpoint: ListeningRoomXPCEndpoint>(_ endpoint: Endpoint, _ request: Data) async throws -> Data {
                    let request = try _endpointDecode(Endpoint.Request.self, from: request)
                    let response = try await endpoint(request)
                    return try _endpointEncode(response)
                }
                let response = try await call(endpoint, request)
                replyHandler(response, nil)
            } catch {
                replyHandler(nil, error)
            }
        }
    }
}
