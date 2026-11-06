import Foundation
import Logger
import UnleashProxyClientSwift

@testable import hCore

/// Stands in for the network under the Unleash SDK: answers each fetch from a queue of canned responses,
/// failing once the queue is empty, and records every URL it was asked for.
final class MockPollerSession: PollerSession, @unchecked Sendable {
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

class MockLogger: Logging {
    var warnings = [String]()

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
