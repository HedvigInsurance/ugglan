import Apollo
import DatadogInternal
import DatadogLogs
import DatadogRUM
import Environment
import Logger
import SwiftUI

class DatadogLogger: Logging {
    private let datadogLogger: LoggerProtocol

    init(datadogLogger: LoggerProtocol) {
        self.datadogLogger = datadogLogger
    }

    func debug(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        if Environment.current != .production {
            datadogLogger.debug(message, error: error, attributes: attributes)
        }
    }

    /// Sends an INFO log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func info(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        datadogLogger.info(message, error: error, attributes: attributes)
    }

    /// Sends a NOTICE log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func notice(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        datadogLogger.notice(message, error: error, attributes: attributes)
    }

    /// Sends a WARN log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func warn(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        datadogLogger.warn(message, error: error, attributes: attributes)
    }

    /// Sends an ERROR log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func error(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        datadogLogger.error(message, error: error, attributes: attributes)
    }

    /// Sends a CRITICAL log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func critical(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        datadogLogger.critical(message, error: error, attributes: attributes)
    }

    func addUserAction(
        type: LoggingAction,
        name: String,
        error _: Error? = nil,
        attributes: [AttributeKey: AttributeValue]? = nil
    ) {
        if let attributes {
            RUMMonitor.shared().addAction(type: type.asRUMUserActionType, name: name, attributes: attributes)
        } else {
            RUMMonitor.shared().addAction(type: type.asRUMUserActionType, name: name)
        }
    }

    func addError(
        error: Error,
        type: ErrorSource,
        attributes: [AttributeKey: AttributeValue]?
    ) {
        if let attributes = attributes {
            RUMMonitor.shared().addError(error: error, source: type.asRUMErrorSource, attributes: attributes)
        } else {
            RUMMonitor.shared().addError(error: error, source: type.asRUMErrorSource)
        }
    }
}

extension ErrorSource {
    var asRUMErrorSource: RUMErrorSource {
        switch self {
        case .network:
            return .network
        }
    }
}

extension LoggingAction {
    var asRUMUserActionType: RUMActionType {
        switch self {
        case .click:
            return .click
        case .custom:
            return .custom
        }
    }
}

@MainActor
class InterceptingURLSessionClient: URLSessionClient {
    override func sendRequest(
        _ request: URLRequest,
        rawTaskCompletionHandler: URLSessionClient.RawCompletion? = nil,
        completion: @escaping URLSessionClient.Completion
    ) -> URLSessionTask {
        guard let instrumentedRequest = URLSessionInterceptor.shared()?.intercept(request: request) else {
            return super
                .sendRequest(request, rawTaskCompletionHandler: rawTaskCompletionHandler, completion: completion)
        }

        let task = super
            .sendRequest(
                instrumentedRequest,
                rawTaskCompletionHandler: rawTaskCompletionHandler,
                completion: completion
            )
        URLSessionInterceptor.shared()?.intercept(task: task)

        return task
    }

    override func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        URLSessionInterceptor.shared()?.task(task, didFinishCollecting: metrics)
        super.urlSession(session, task: task, didFinishCollecting: metrics)
    }

    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        URLSessionInterceptor.shared()?.task(task, didCompleteWithError: error)
        super.urlSession(session, task: task, didCompleteWithError: error)
    }

    override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        URLSessionInterceptor.shared()?.task(dataTask, didReceive: data)
        super.urlSession(session, dataTask: dataTask, didReceive: data)
    }
}
