import Combine
import Foundation
import Logger
import UnleashProxyClientSwift

@testable import hCore

/// Feeds `FeatureFlags.shared` whatever feature data a test needs.
final class FakeFeatureFlagsClient: FeatureFlagsClient, @unchecked Sendable {
    private let subject = PassthroughSubject<FeatureData, Never>()

    var featureData: AnyPublisher<FeatureData, Never> {
        subject.eraseToAnyPublisher()
    }

    func setup(with _: [String: String]) async throws {}
    func updateContext(context _: [String: String]) {}

    func send(_ data: FeatureData) {
        subject.send(data)
    }
}

extension FeatureData {
    static func allOff(experiments: [Experiment]?, isPuppyGuideEnabled: Bool = false) -> FeatureData {
        FeatureData(
            isUpdateNecessary: false,
            isSubmitClaimEnabled: false,
            osVersionTooLow: false,
            emailPreferencesEnabled: false,
            isDemoMode: false,
            isAddonsRemovalFromMovingFlowEnabled: false,
            isNewConversationFromInboxEnabled: false,
            isPuppyGuideEnabled: isPuppyGuideEnabled,
            isResumeClaimEnabled: false,
            isOnboardingEnabled: false,
            isTerminationRedirectionEnabled: false,
            isAnalyticsEnabled: false,
            isResumingOngoingShopSessionsEnabled: false,
            experiments: experiments
        )
    }
}

@MainActor
final class FakeEventTrackingClient: EventTrackingClient {
    /// Every `setUserProperty` call in order, so a test can tell "cleared" from "never touched".
    private(set) var userPropertyChanges: [(name: String, value: String?)] = []

    /// The latest value set per property; a key is absent until the property has been set at all.
    var userProperties: [String: String?] {
        var properties: [String: String?] = [:]
        for change in userPropertyChanges {
            properties[change.name] = change.value
        }
        return properties
    }

    func setCollectionEnabled(_: Bool) {}
    func trackEvent(name _: String, parameters _: [String: Any]?) {}
    func trackScreen(name _: String, parameters _: [String: Any]?) {}
    func setUserId(_: String?) {}

    func setUserProperty(name: String, value: String?) {
        userPropertyChanges.append((name, value))
    }
}

/// Stands in for the network under the Unleash SDK: answers each fetch from a queue of canned responses,
/// failing once the queue is empty, and records every URL it was asked for.
final class FakePollerSession: PollerSession, @unchecked Sendable {
    struct Response {
        let statusCode: Int
        let body: Data

        static func toggles(_ json: String) -> Response {
            Response(statusCode: 200, body: Data(json.utf8))
        }

        static let notModified = Response(statusCode: 304, body: Data())
    }

    private let lock = NSLock()
    private var queue: [Response] = []
    private var urls: [URL] = []

    var requestedURLs: [URL] {
        lock.lock()
        defer { lock.unlock() }
        return urls
    }

    func enqueue(_ response: Response) {
        lock.lock()
        queue.append(response)
        lock.unlock()
    }

    func perform(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = request.url else { return }
        lock.lock()
        urls.append(url)
        let response = queue.isEmpty ? nil : queue.removeFirst()
        lock.unlock()
        guard let response else {
            completionHandler(nil, nil, URLError(.notConnectedToInternet))
            return
        }
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: response.statusCode,
            httpVersion: nil,
            headerFields: ["Etag": "\"\(response.body.count)\""]
        )
        completionHandler(response.body, httpResponse, nil)
    }
}

/// Records the warnings logged, so a test can tell the app reported a fallback.
final class FakeLogger: Logging {
    private(set) var warnings: [String] = []

    func debug(_: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {}
    func info(_: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {}
    func notice(_: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {}

    func warn(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        warnings.append(message)
    }

    func error(_: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {}
    func critical(_: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {}
    func addUserAction(
        type _: LoggingAction,
        name _: String,
        error _: Error?,
        attributes _: [AttributeKey: AttributeValue]?
    ) {}
    func addError(error _: Error, type _: ErrorSource, attributes _: [AttributeKey: AttributeValue]?) {}
}
