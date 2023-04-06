import Apollo
import Claims
import Datadog
import Foundation
import Odyssey
import OdysseyKit
import hCore
import hGraphQL

extension TokenRefresher: OdysseyKit.AccessTokenProvider {
    public func provide() async -> String? {
        await withCheckedContinuation { continuation in
            refreshIfNeeded()
                .onValue { _ in
                    continuation.resume(returning: ApolloClient.retreiveToken()?.accessToken)
                }
        }
    }
}

class OdysseyDatadogLogger: DatadogLogger {
    func debug(tag: String, message: String) {
        log.debug("\(tag) : \(message)")
    }

    func error(tag: String, message: String) {
        log.error("\(tag) : \(message)")
    }

    func info(tag: String, message: String) {
        log.info("\(tag) : \(message)")
    }

    func warn(tag: String, message: String) {
        log.warn("\(tag) : \(message)")
    }
}

class OdysseyDatadogProvider: DatadogProvider {
    let serialQueue = DispatchQueue(label: "datadog.span.serial.queue")

    var spans: [String: OTSpan] = [:]

    func end(response: OdysseyHTTPResponse) {
        serialQueue.sync {
            if let spanId = response.getAttribute(key: "span-id"),
                let span = spans[spanId]
            {
                span.setTag(key: "http.status_code", value: response.statusCode)

                spans[spanId]?.finish()
                spans[spanId] = nil
            }
        }
    }

    func start(request: OdysseyHTTPRequest) -> [String: String] {
        let span = Global.sharedTracer.startSpan(
            operationName: "\(request.path)"
        )
        let spanId = UUID().uuidString

        serialQueue.sync {
            spans[spanId] = span
        }

        span.setTag(key: "http.url", value: request.url)
        span.setTag(key: "http.method", value: request.method)

        request.addAttribute(key: "span-id", value: spanId)

        let headersWriter = HTTPHeadersWriter()
        Global.sharedTracer.inject(spanContext: span.context, writer: headersWriter)

        return headersWriter.tracePropagationHTTPHeaders
    }

    var logger: DatadogLogger = OdysseyDatadogLogger()
}

extension AppDelegate {
    func initOdyssey() {
        OdysseyKit.initialize(
            apiUrl: Environment.current.odysseyApiURL.absoluteString,
            accessTokenProvider: TokenRefresher.shared,
            datadogProvider: OdysseyDatadogProvider(),
            locale: Localization.Locale.currentLocale.acceptLanguageHeader,
            enableNetworkLogs: false
        )

        let odysseyNetworkClient = OdysseyNetworkClient()
        Dependencies.shared.add(
            module: Module { () -> FileUploaderClient in
                odysseyNetworkClient
            }
        )
    }
}
