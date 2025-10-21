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
class InterceptingURLSessionClient: NSObject, URLSessionDataDelegate {}
