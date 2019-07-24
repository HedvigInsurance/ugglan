//
//  MockWebSocket.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import ApolloWebSocket
import Foundation
import Starscream

class MockWebSocket: ApolloWebSocketClient {
    var pongDelegate: WebSocketPongDelegate?

    var sslClientCertificate: SSLClientCertificate?

    required init(request _: URLRequest, protocols _: [String]?) {}

    public init() {}

    open func write(string: String, completion _: (() -> Void)?) {
        delegate?.websocketDidReceiveMessage(socket: self, text: string)
    }

    open func write(data _: Data, completion _: (() -> Void)?) {}

    open func write(ping _: Data, completion _: (() -> Void)?) {}

    open func write(pong _: Data, completion _: (() -> Void)?) {}

    func disconnect(forceTimeout _: TimeInterval?, closeCode _: UInt16) {}

    public var disableSSLCertValidation = false
    public var overrideTrustHostname = false
    public var desiredTrustHostname: String?

    var delegate: WebSocketDelegate?
    var security: SSLTrustValidator?
    var enabledSSLCipherSuites: [SSLCipherSuite]? = []
    var isConnected: Bool = false

    func connect() {}
}
