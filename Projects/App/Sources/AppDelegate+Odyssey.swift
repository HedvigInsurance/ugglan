import Apollo
import Foundation
import OdysseyKit
import hCore
import hGraphQL
import Odyssey
import Datadog

extension TokenRefresher: OdysseyKit.AccessTokenProvider {
    public func provide() async -> String? {
        await withCheckedContinuation { continuation in
            refreshIfNeeded().onValue { _ in
                continuation.resume(returning: ApolloClient.retreiveToken()?.accessToken)
            }
        }
    }
}

class OdysseyDatadogSpanProvider: DatadogSpanProvider {
    var spans: [String: OTSpan] = [:]

    func end(response: OdysseyHTTPResponse) {
        if let spanId = response.getAttribute(key: "span-id"),
            let span = spans[spanId]
        {
            span.setTag(key: "http.status_code", value: response.statusCode)

            spans[spanId]?.finish()
            spans[spanId] = nil
        }
    }

    func start(request: OdysseyHTTPRequest) -> [String: String] {
        let span = Global.sharedTracer.startSpan(
            operationName: "\(request.path)"
        )
        let spanId = UUID().uuidString

        spans[spanId] = span

        span.setTag(key: "http.url", value: request.url)
        span.setTag(key: "http.method", value: request.method)

        request.addAttribute(key: "span-id", value: spanId)

        let headersWriter = HTTPHeadersWriter()
        Global.sharedTracer.inject(spanContext: span.context, writer: headersWriter)

        return headersWriter.tracePropagationHTTPHeaders
    }
}

extension AppDelegate {
    func initOdyssey() {
        OdysseyKit.initialize(
            apiUrl: Environment.current.odysseyApiURL.absoluteString,
            accessTokenProvider: TokenRefresher.shared,
            datadogSpanProvider: OdysseyDatadogSpanProvider(),
            locale: Localization.Locale.currentLocale.acceptLanguageHeader,
            enableNetworkLogs: true
        )
    }
}
